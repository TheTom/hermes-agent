import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_mobile/core/db/app_database.dart';
import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/network/dashboard_client.dart';
import 'package:hermes_mobile/core/sync/gateway_realtime.dart';
import 'package:hermes_mobile/core/sync/session_sync_repository.dart';

/// Sync-conflict-on-reconnect coverage: a phone whose socket dropped (or that
/// was offline outright) reconnects to a gateway whose state has moved on.
///
/// Every test drives a **real** local `dart:io` server — both the `/api/ws`
/// JSON-RPC socket and the dashboard REST routes the client actually pulls
/// from — so `GatewayWsClient` / `GatewayRealtime` / `DashboardClient` are
/// exercised as written, exactly as against a live gateway. Nothing at the
/// client layer is mocked.
///
/// The server model deliberately reproduces the two gateway behaviours the
/// client has to survive:
/// - message ids are `AUTOINCREMENT` row ids (`hermes_state.py get_messages`
///   returns `SELECT *` straight off the `messages` table), and
/// - a rewind (`replace_messages(..., archive_dropped=True)`) soft-archives
///   the live rows and re-inserts the survivors as **fresh rows with new
///   ids**, so an edit on another client re-stamps the whole transcript.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => Directory.systemTemp.path,
      );

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('sessions created offline', () {
    test('a draft created while the socket was down delivers its queued first '
        'message once the socket comes back', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);

      final sync = SessionSyncRepository(
        gatewayId: 'gw-draft',
        db: db,
        dashboard: gw.dashboard(),
      );

      // No realtime bound yet == no live socket: createSession falls back to a
      // local_* draft, and (under the shipped cookie auth, which has no
      // HermesApi) enqueues NO create_session op.
      final session = await sync.createSession(title: 'Offline chat');
      expect(session.id, startsWith('local_'));

      final queued = await sync.sendMessage(
        sessionId: session.id,
        input: 'hello from the tunnel',
      );
      expect(queued.queued, isTrue);
      expect(await db.pendingOpsForGateway('gw-draft'), hasLength(1));

      final realtime = GatewayRealtime(
        profile: gw.openProfile(),
        sessionSync: sync,
      );
      sync.bindRealtime(realtime);
      addTearDown(realtime.dispose);
      expect(await realtime.ensureLive(), isTrue);

      await _drainOutbox(sync, db, 'gw-draft');

      expect(
        await db.pendingOpsForGateway('gw-draft'),
        isEmpty,
        reason:
            'the stranded draft must be promoted (session.create) and its '
            'queued message delivered, not retried forever',
      );
      expect(gw.sessionCreateCalls, 1);
      expect(gw.promptSubmits, hasLength(1));
      expect(gw.promptSubmits.single['text'], 'hello from the tunnel');
      expect(gw.serverTranscript(gw.storedIds.single), [
        'user:hello from the tunnel',
        'assistant:ack hello from the tunnel',
      ]);
    });
  });

  group('sessions deleted on one side', () {
    test('a session deleted here does not reappear on the next pull while its '
        'delete op is still queued, and its tombstone is dropped once the '
        'server confirms', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('sess-a', title: 'Alpha');
      gw.addSession('sess-b', title: 'Beta');
      gw.rejectDeletes = true;

      final sync = SessionSyncRepository(
        gatewayId: 'gw-del',
        db: db,
        dashboard: gw.dashboard(),
      );

      expect(
        (await sync.syncSessions()).map((s) => s.id),
        containsAll(['sess-a', 'sess-b']),
      );

      // The DELETE cannot be delivered, so the op lands in the outbox and the
      // row stays `deleted_pending`.
      await sync.deleteSession('sess-a');
      expect(await db.pendingOpsForGateway('gw-del'), hasLength(1));
      expect(
        (await sync.loadSessionsLocal()).map((s) => s.id),
        isNot(contains('sess-a')),
      );

      // The gateway still lists it. A blind replace used to re-insert it as
      // `synced` — the deleted session came back in the list.
      final afterPull = await sync.syncSessions(bypassTtl: true);
      expect(
        afterPull.map((s) => s.id),
        isNot(contains('sess-a')),
        reason: 'the local delete tombstone must win until the server agrees',
      );
      expect(afterPull.map((s) => s.id), contains('sess-b'));

      // Server confirms the deletion → the tombstone has done its job and is
      // dropped, so a *newly created* session reusing that id is not hidden.
      gw.removeSession('sess-a');
      await sync.syncSessions(bypassTtl: true);
      gw.addSession('sess-a', title: 'Alpha rebuilt');
      expect(
        (await sync.syncSessions(bypassTtl: true)).map((s) => s.id),
        contains('sess-a'),
        reason: 'a confirmed delete must not leave a permanent tombstone',
      );
    });
  });

  group('synthetic timeline markers vs a pull', () {
    test('a carried-over local row keeps its display_kind', () async {
      // `syncMessages` re-inserts local rows the server has not echoed
      // (`carry()`). It rebuilt them field by field and omitted
      // `display_kind`, so a `role: user` marker came back as a *visible*
      // user turn — which shifts every later user ordinal and is exactly the
      // mismatch the gateway rejects with error 4018.
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('sess-dk', title: 'Chat');
      gw.appendMessage('sess-dk', 'user', 'hello');
      gw.appendMessage('sess-dk', 'assistant', 'hi');

      final sync = SessionSyncRepository(
        gatewayId: 'gw-dk',
        db: db,
        dashboard: gw.dashboard(),
      );
      await sync.syncMessages('sess-dk');

      await db.upsertMessage(
        CachedMessagesCompanion.insert(
          gatewayId: 'gw-dk',
          sessionId: 'sess-dk',
          id: 'local_marker',
          role: 'user',
          content: const Value('/model gpt-x'),
          sortIndex: const Value(99),
          syncStatus: const Value('pending'),
          displayKind: const Value('model_switch'),
        ),
      );

      final merged = await sync.syncMessages('sess-dk');
      final marker = merged.firstWhere((m) => m.id == 'local_marker');
      expect(marker.displayKind, 'model_switch');
      expect(
        marker.isVisibleUser,
        isFalse,
        reason: 'a tagged marker is not a user turn the gateway counts',
      );
    });
  });

  group('message tombstones vs a server-side rewind', () {
    test('a locally deleted message stays deleted after the gateway rewinds '
        'and re-stamps every row id', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('s1', title: 'Chat');
      gw.appendMessage('s1', 'user', 'first');
      gw.appendMessage('s1', 'assistant', 'reply');
      gw.appendMessage('s1', 'user', 'oops wrong thing');
      gw.appendMessage('s1', 'assistant', 'sure');

      final sync = SessionSyncRepository(
        gatewayId: 'gw-tomb',
        db: db,
        dashboard: gw.dashboard(),
      );
      await sync.syncMessages('s1');

      final oops = (await sync.loadMessagesLocal(
        's1',
      )).firstWhere((m) => m.content == 'oops wrong thing');
      await sync.deleteMessageLocal('s1', oops.id);
      expect(
        (await sync.loadMessagesLocal('s1')).any((m) => m.id == oops.id),
        isFalse,
      );

      // Desktop edits the LAST turn: the gateway truncates to the first three
      // messages and re-inserts the survivors as fresh rows — every id in the
      // session changes — then runs the replacement turn.
      gw.rewind('s1', keep: 3);
      gw.appendMessage('s1', 'assistant', 'new reply');
      expect(
        gw.messageIds('s1').contains(oops.id),
        isFalse,
        reason: 'sanity: the rewind must have re-stamped the row ids',
      );

      final after = await sync.syncMessages('s1');
      expect(
        after.any((m) => m.content == 'oops wrong thing'),
        isFalse,
        reason:
            'the tombstone must follow the message to its new row id instead '
            'of silently letting the deleted message resurrect',
      );
      expect(after.map((m) => m.content).toList(), [
        'first',
        'reply',
        'new reply',
      ]);

      final tombstones = await db.tombstonesForSession('gw-tomb', 's1');
      expect(tombstones, hasLength(1));
      expect(
        tombstones.single.messageId,
        isNot(oops.id),
        reason: 'the tombstone was re-pointed at the row id the server now has',
      );
    });

    test('a tombstone whose message the gateway no longer has at all is '
        'dropped rather than left to hide an unrelated row', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('s2', title: 'Chat');
      gw.appendMessage('s2', 'user', 'keep me');
      gw.appendMessage('s2', 'assistant', 'ok');
      gw.appendMessage('s2', 'user', 'delete me');

      final sync = SessionSyncRepository(
        gatewayId: 'gw-gc',
        db: db,
        dashboard: gw.dashboard(),
      );
      await sync.syncMessages('s2');
      final target = (await sync.loadMessagesLocal(
        's2',
      )).firstWhere((m) => m.content == 'delete me');
      await sync.deleteMessageLocal('s2', target.id);
      expect(await db.tombstonesForSession('gw-gc', 's2'), hasLength(1));

      // The rewind cuts past the deleted turn: it is gone server-side.
      gw.rewind('s2', keep: 2);
      await sync.syncMessages('s2');

      expect(
        await db.tombstonesForSession('gw-gc', 's2'),
        isEmpty,
        reason:
            'nothing left to hide — a kept tombstone could later mask an '
            'unrelated message that inherits the id',
      );
      expect(
        (await sync.loadMessagesLocal('s2')).map((m) => m.content).toList(),
        ['keep me', 'ok'],
      );
    });
  });

  group('outbox give-up', () {
    test('a queued message the live gateway permanently rejects is abandoned '
        'with a visible error instead of replayed forever', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('sess-x', title: 'Chat');
      gw.promptSubmitError = {
        'code': 4018,
        'message': 'target user message is no longer in session history',
      };

      final sync = SessionSyncRepository(
        gatewayId: 'gw-term',
        db: db,
        dashboard: gw.dashboard(),
      );
      await sync.syncSessions();

      // Queue the send while the socket is down.
      final queued = await sync.sendMessage(
        sessionId: 'sess-x',
        input: 'this can never land',
      );
      expect(queued.queued, isTrue);
      expect(await db.pendingOpsForGateway('gw-term'), hasLength(1));

      final realtime = GatewayRealtime(
        profile: gw.openProfile(),
        sessionSync: sync,
      );
      sync.bindRealtime(realtime);
      addTearDown(realtime.dispose);
      expect(await realtime.ensureLive(), isTrue);
      await _drainOutbox(sync, db, 'gw-term');

      expect(
        await db.pendingOpsForGateway('gw-term'),
        isEmpty,
        reason: 'a permanent rejection must not sit in the outbox forever',
      );
      expect(
        gw.promptSubmits,
        hasLength(1),
        reason: 'and must not be replayed on every reconnect',
      );
      final local = await sync.loadMessagesLocal('sess-x');
      expect(
        local.any((m) => (m.content ?? '').contains('no longer in session')),
        isTrue,
        reason: 'the user has to be told the message was never delivered',
      );
      expect(
        local.any((m) => m.content == 'this can never land'),
        isTrue,
        reason: 'their own text is kept, only the false promise is dropped',
      );
    });

    test('an op that has burned the attempt ceiling against a reachable '
        'gateway is abandoned too', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('sess-y', title: 'Chat');
      // Not a terminal 4018 — a generic server-side failure that would
      // otherwise be retried indefinitely.
      gw.promptSubmitError = {'code': 5000, 'message': 'internal error'};

      final sync = SessionSyncRepository(
        gatewayId: 'gw-cap',
        db: db,
        dashboard: gw.dashboard(),
      );
      // The state an offline send leaves behind, one attempt short of the
      // ceiling: the user's row in the cache plus the op in the outbox.
      await db.upsertMessage(
        CachedMessagesCompanion.insert(
          gatewayId: 'gw-cap',
          sessionId: 'sess-y',
          id: 'local-user-1',
          role: 'user',
          content: const Value('nearly out of tries'),
          syncStatus: const Value('pending'),
        ),
      );
      await db.enqueueOp(
        PendingOpsCompanion.insert(
          id: 'op-worn-out',
          gatewayId: 'gw-cap',
          opType: 'chat',
          sessionId: const Value('sess-y'),
          payloadJson: jsonEncode({
            'session_id': 'sess-y',
            'input': 'nearly out of tries',
            'local_user_message_id': 'local-user-1',
          }),
          attemptCount: Value(SessionSyncRepository.maxOutboxAttempts - 1),
          createdAt: DateTime.now().toUtc(),
        ),
      );

      final realtime = GatewayRealtime(
        profile: gw.openProfile(),
        sessionSync: sync,
      );
      sync.bindRealtime(realtime);
      addTearDown(realtime.dispose);
      expect(await realtime.ensureLive(), isTrue);
      await _drainOutbox(sync, db, 'gw-cap');

      expect(await db.pendingOpsForGateway('gw-cap'), isEmpty);
      expect(
        (await sync.loadMessagesLocal(
          'sess-y',
        )).any((m) => (m.content ?? '').contains('Not delivered after')),
        isTrue,
      );
    });

    test('two queued ops for one session do not break the "still queued?" '
        'check', () async {
      final now = DateTime.now().toUtc();
      for (final id in ['op-1', 'op-2']) {
        await db.enqueueOp(
          PendingOpsCompanion.insert(
            id: id,
            gatewayId: 'gw-two',
            opType: 'chat',
            sessionId: const Value('sess-z'),
            payloadJson: jsonEncode({'session_id': 'sess-z', 'input': id}),
            createdAt: now,
          ),
        );
      }
      final sync = SessionSyncRepository(gatewayId: 'gw-two', db: db);
      expect(await sync.hasPendingOpsFor('sess-z'), isTrue);
      expect(await sync.hasPendingOpsFor('sess-other'), isFalse);
    });

    test(
      'concurrent reconnect workers can lease a queued message only once',
      () async {
        await db.enqueueOp(
          PendingOpsCompanion.insert(
            id: 'op-lease',
            gatewayId: 'gw-lease',
            opType: 'chat',
            sessionId: const Value('sess-lease'),
            payloadJson: jsonEncode({
              'session_id': 'sess-lease',
              'input': 'send exactly once',
            }),
            createdAt: DateTime.now().toUtc(),
          ),
        );

        final claims = await Future.wait([
          db.claimPendingOp('op-lease'),
          db.claimPendingOp('op-lease'),
          db.claimPendingOp('op-lease'),
        ]);

        expect(
          claims.whereType<PendingOp>(),
          hasLength(1),
          reason:
              'foreground, reconnect, and background flushes share one lease',
        );
      },
    );
  });

  group('outbox ordering vs turns run elsewhere', () {
    test('queued messages replay in order and land after the turns the '
        'gateway ran meanwhile', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('sess-o', title: 'Chat');
      gw.appendMessage('sess-o', 'user', 'from the phone earlier');
      gw.appendMessage('sess-o', 'assistant', 'earlier reply');

      final sync = SessionSyncRepository(
        gatewayId: 'gw-order',
        db: db,
        dashboard: gw.dashboard(),
      );
      await sync.syncSessions();
      await sync.syncMessages('sess-o');

      // Two sends while the socket is down.
      expect(
        (await sync.sendMessage(sessionId: 'sess-o', input: 'one')).queued,
        isTrue,
      );
      expect(
        (await sync.sendMessage(sessionId: 'sess-o', input: 'two')).queued,
        isTrue,
      );
      expect(await db.pendingOpsForGateway('gw-order'), hasLength(2));

      // Meanwhile Desktop ran a turn on the same session.
      gw.appendMessage('sess-o', 'user', 'from desktop');
      gw.appendMessage('sess-o', 'assistant', 'desktop reply');

      final realtime = GatewayRealtime(
        profile: gw.openProfile(),
        sessionSync: sync,
      );
      sync.bindRealtime(realtime);
      addTearDown(realtime.dispose);
      expect(await realtime.ensureLive(), isTrue);
      await _drainOutbox(sync, db, 'gw-order');

      expect(
        gw.promptSubmits.map((p) => p['text']).toList(),
        ['one', 'two'],
        reason: 'the outbox must not reorder the user\'s messages',
      );
      expect(gw.serverTranscript('sess-o'), [
        'user:from the phone earlier',
        'assistant:earlier reply',
        'user:from desktop',
        'assistant:desktop reply',
        'user:one',
        'assistant:ack one',
        'user:two',
        'assistant:ack two',
      ]);
      expect(
        (await sync.syncMessages('sess-o')).map((m) => m.content).toList(),
        [
          'from the phone earlier',
          'earlier reply',
          'from desktop',
          'desktop reply',
          'one',
          'ack one',
          'two',
          'ack two',
        ],
        reason:
            'the local cache must match the gateway, with no duplicated or '
            'stranded copies of the replayed messages',
      );
    });
  });

  group('local error bubbles', () {
    test('a terminal error whose message the gateway does have does not stay '
        'pinned below later successful turns', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('sess-e', title: 'Chat');
      gw.appendMessage('sess-e', 'user', 'edit me');
      gw.appendMessage('sess-e', 'assistant', 'old reply');

      final sync = SessionSyncRepository(
        gatewayId: 'gw-err',
        db: db,
        dashboard: gw.dashboard(),
      );
      await sync.syncMessages('sess-e');

      // An edit whose cached ordinal the gateway refuses: permanently
      // rejected, so a terminal error bubble is persisted. The user's text is
      // already in the server transcript (that is what "edit" means), so
      // nothing undelivered is left behind once this pull resolves.
      gw.promptSubmitError = {
        'code': 4018,
        'message': 'target user message is no longer in session history',
      };
      final realtime = GatewayRealtime(
        profile: gw.openProfile(),
        sessionSync: sync,
      );
      sync.bindRealtime(realtime);
      addTearDown(realtime.dispose);
      expect(await realtime.ensureLive(), isTrue);

      final failed = await sync.sendMessage(
        sessionId: 'sess-e',
        input: 'edit me',
        truncateBeforeUserOrdinal: 0,
      );
      expect(failed.error, contains('no longer in session history'));
      expect(
        (await sync.loadMessagesLocal(
          'sess-e',
        )).any((m) => (m.content ?? '').contains('no longer in session')),
        isTrue,
        reason: 'the failure must be visible while it is the latest thing',
      );

      // The gateway then answers a later turn successfully.
      gw.promptSubmitError = null;
      await sync.sendMessage(sessionId: 'sess-e', input: 'carry on');

      final after = await sync.syncMessages('sess-e');
      expect(
        after.any((m) => (m.content ?? '').contains('no longer in session')),
        isFalse,
        reason:
            'a stale error bubble must not outlive the failure and sit under '
            'every later successful turn',
      );
      expect(after.last.content, 'ack carry on');
    });

    test('a terminal error whose message never reached the gateway is kept '
        'alongside the undelivered message', () async {
      final gw = await _ConflictGateway.start();
      addTearDown(gw.close);
      gw.addSession('sess-k', title: 'Chat');
      gw.appendMessage('sess-k', 'user', 'earlier');
      gw.appendMessage('sess-k', 'assistant', 'earlier reply');
      gw.promptSubmitError = {'code': 4018, 'message': 'image too large'};

      final sync = SessionSyncRepository(
        gatewayId: 'gw-keep',
        db: db,
        dashboard: gw.dashboard(),
      );
      await sync.syncMessages('sess-k');
      final realtime = GatewayRealtime(
        profile: gw.openProfile(),
        sessionSync: sync,
      );
      sync.bindRealtime(realtime);
      addTearDown(realtime.dispose);
      expect(await realtime.ensureLive(), isTrue);

      await sync.sendMessage(sessionId: 'sess-k', input: 'a huge photo');

      final after = await sync.syncMessages('sess-k');
      expect(
        after.map((m) => m.content).toList(),
        containsAllInOrder(['earlier', 'earlier reply', 'a huge photo']),
      );
      expect(
        after.last.content,
        contains('image too large'),
        reason:
            'the message never reached the gateway — dropping the explanation '
            'while keeping the unsent text is the silent half of the bug',
      );
    });
  });
}

/// Poll the outbox until it drains, nudging the flush each pass.
///
/// A successful connect already fires `flushPendingOverWs()` fire-and-forget,
/// and the repository's `_flushing` guard makes a second concurrent call a
/// no-op — so this waits on the real drain rather than racing it.
Future<void> _drainOutbox(
  SessionSyncRepository sync,
  AppDatabase db,
  String gatewayId,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(deadline)) {
    if ((await db.pendingOpsForGateway(gatewayId)).isEmpty) return;
    await sync.flushPendingOverWs();
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}

/// `TestWidgetsFlutterBinding` installs an `HttpOverrides` that answers every
/// `HttpClient` request with a canned 400 and never touches the network. That
/// is the right default, but these tests DO want a real socket — to the
/// loopback server started in-process. Build the client under the SDK's own
/// (non-overridden) `HttpOverrides` so Dio talks to it for real.
class _RealHttpOverrides extends HttpOverrides {}

HttpClient _realHttpClient() =>
    HttpOverrides.runWithHttpOverrides(HttpClient.new, _RealHttpOverrides());

/// A local stand-in for `tui_gateway` that serves BOTH surfaces the client
/// uses: the `/api/ws` JSON-RPC socket and the dashboard REST routes.
///
/// Message ids are assigned from one monotonically increasing counter, exactly
/// like the gateway's `messages.id AUTOINCREMENT`, and [rewind] re-stamps the
/// survivors with fresh ids the way `replace_messages(...,
/// archive_dropped=True)` does.
class _ConflictGateway {
  _ConflictGateway(this.server);

  final HttpServer server;
  final List<WebSocket> _sockets = [];

  final List<Map<String, dynamic>> _sessions = [];
  final Map<String, List<Map<String, dynamic>>> _transcripts = {};
  final Map<String, String> _storedByLive = {};
  final List<String> storedIds = [];

  int _nextRowId = 1;
  int _nextSession = 1;
  int sessionCreateCalls = 0;
  final List<Map<String, dynamic>> promptSubmits = [];

  /// When set, every `prompt.submit` is refused with this JSON-RPC error.
  Map<String, dynamic>? promptSubmitError;

  /// When true, `DELETE /api/sessions/{id}` answers 403 so the client's delete
  /// falls back to the outbox.
  bool rejectDeletes = false;

  static Future<_ConflictGateway> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final gw = _ConflictGateway(server);
    server.listen(gw._onRequest);
    return gw;
  }

  ConnectionProfile openProfile() => ConnectionProfile(
    id: 'test-gw',
    baseUrl: 'http://127.0.0.1:${server.port}',
    authMode: 'open',
  );

  DashboardClient dashboard() {
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}'))
      ..httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: _realHttpClient,
      );
    return DashboardClient(profile: openProfile(), dio: dio);
  }

  // ── server-side state helpers ────────────────────────────────────────

  void addSession(String id, {String? title}) {
    _sessions.removeWhere((s) => s['id'] == id);
    _sessions.add({
      'id': id,
      'title': title,
      'source': 'mobile',
      'message_count': _transcripts[id]?.length ?? 0,
      'last_active': DateTime.now().toUtc().toIso8601String(),
    });
    _transcripts.putIfAbsent(id, () => []);
  }

  void removeSession(String id) {
    _sessions.removeWhere((s) => s['id'] == id);
    _transcripts.remove(id);
  }

  void appendMessage(String sessionId, String role, String content) {
    final list = _transcripts.putIfAbsent(sessionId, () => []);
    list.add({
      'id': '${_nextRowId++}',
      'session_id': sessionId,
      'role': role,
      'content': content,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Truncate to the first [keep] messages, re-inserting the survivors as
  /// fresh rows with brand-new ids (gateway `replace_messages` semantics).
  void rewind(String sessionId, {required int keep}) {
    final list = _transcripts[sessionId] ?? [];
    final survivors = list.take(keep).toList();
    _transcripts[sessionId] = [
      for (final m in survivors)
        {
          ...m,
          'id': '${_nextRowId++}',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
    ];
  }

  List<String> messageIds(String sessionId) => [
    for (final m in _transcripts[sessionId] ?? []) '${m['id']}',
  ];

  List<String> serverTranscript(String sessionId) => [
    for (final m in _transcripts[sessionId] ?? [])
      '${m['role']}:${m['content']}',
  ];

  // ── REST + WS plumbing ───────────────────────────────────────────────

  Future<void> _onRequest(HttpRequest req) async {
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      final ws = await WebSocketTransformer.upgrade(req);
      _sockets.add(ws);
      ws.listen((raw) => _onRpc(ws, raw));
      return;
    }
    final path = req.uri.path;
    final res = req.response;
    res.headers.contentType = ContentType.json;

    if (req.method == 'GET' && path == '/api/sessions') {
      res.write(jsonEncode({'sessions': _sessions}));
    } else if (req.method == 'GET' &&
        path.startsWith('/api/sessions/') &&
        path.endsWith('/messages')) {
      final sid = Uri.decodeComponent(
        path.substring(
          '/api/sessions/'.length,
          path.length - '/messages'.length,
        ),
      );
      res.write(jsonEncode({'messages': _transcripts[sid] ?? []}));
    } else if (req.method == 'DELETE' && path.startsWith('/api/sessions/')) {
      if (rejectDeletes) {
        res.statusCode = HttpStatus.forbidden;
        res.write(jsonEncode({'detail': 'forbidden'}));
      } else {
        removeSession(
          Uri.decodeComponent(path.substring('/api/sessions/'.length)),
        );
        res.write(jsonEncode({'ok': true}));
      }
    } else if (path == '/api/status') {
      res.write(jsonEncode({'ok': true}));
    } else {
      res.statusCode = HttpStatus.notFound;
      res.write(jsonEncode({'detail': 'not found'}));
    }
    await res.close();
  }

  void _onRpc(WebSocket ws, dynamic raw) {
    final map = jsonDecode(raw as String) as Map<String, dynamic>;
    final id = map['id'];
    final method = map['method'] as String?;
    final params =
        (map['params'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    switch (method) {
      case 'session.list':
        _reply(ws, id, result: {'sessions': _sessions});
        return;
      case 'session.create':
        sessionCreateCalls++;
        final n = _nextSession++;
        final live = 'live-$n';
        final stored = 'server-$n';
        _storedByLive[live] = stored;
        storedIds.add(stored);
        addSession(stored, title: params['title'] as String?);
        _reply(
          ws,
          id,
          result: {'session_id': live, 'stored_session_id': stored},
        );
        return;
      case 'session.resume':
        _reply(ws, id, result: {'session_id': params['session_id']});
        return;
      case 'prompt.submit':
        promptSubmits.add(params);
        final err = promptSubmitError;
        if (err != null) {
          _reply(ws, id, error: err);
          return;
        }
        final wireId = '${params['session_id']}';
        final sid = _storedByLive[wireId] ?? wireId;
        final text = '${params['text']}';
        appendMessage(sid, 'user', text);
        appendMessage(sid, 'assistant', 'ack $text');
        _reply(ws, id, result: {'status': 'streaming'});
        // Terminal event so the client's turnDone future resolves instead of
        // waiting out the real 30-minute safety timeout.
        Future.microtask(() {
          for (final socket in _sockets) {
            socket.add(
              jsonEncode({
                'method': 'event',
                'params': {
                  'type': 'message.complete',
                  'session_id': params['session_id'],
                  'text': 'ack $text',
                },
              }),
            );
          }
        });
        return;
      default:
        _reply(ws, id, result: {});
    }
  }

  void _reply(
    WebSocket ws,
    dynamic id, {
    Map<String, dynamic>? result,
    Map<String, dynamic>? error,
  }) {
    ws.add(
      jsonEncode({
        'id': id,
        if (error != null) 'error': error else 'result': result ?? {},
      }),
    );
  }

  Future<void> close() async {
    for (final ws in _sockets) {
      await ws.close();
    }
    await server.close(force: true);
  }
}
