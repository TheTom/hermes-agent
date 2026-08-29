import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_mobile/core/db/app_database.dart';
import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/sync/gateway_realtime.dart';
import 'package:hermes_mobile/core/sync/session_sync_repository.dart';

/// Reproduces the device-reported defect end to end over a **real** local
/// WebSocket server (no mocking of GatewayWsClient/GatewayRealtime — the
/// same classes talk to a real socket, exactly like against a live gateway).
///
/// Root cause: the gateway's `_history_user_indices` excludes `display_kind`
/// timeline markers (model_switch, …) from the visible-user-turn count that
/// backs `truncate_before_user_ordinal`; the mobile client used to count
/// every `role: "user"` row, including markers, drifting its ordinal ahead of
/// the gateway's and getting refused with 4018 ("target user message is no
/// longer in session history") on ANY edit/retry after a marker landed.
/// [HermesMessage.isVisibleUser] fixes the count; these tests cover the
/// belt-and-suspenders recovery path for whatever ordinal drift that fix
/// doesn't eliminate (a concurrent edit from another client, etc.).
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

  test('stale-target 4018 retries once without the ordinal, succeeds, and '
      'never touches the outbox', () async {
    final gw = await _FakeGateway.start(
      // First prompt.submit (carries the ordinal) is refused; the retry
      // (no ordinal) succeeds.
      promptSubmitBehavior: (params, callIndex) {
        if (callIndex == 1 &&
            params.containsKey('truncate_before_user_ordinal')) {
          return _FakeResponse.error(
            4018,
            'target user message is no longer in session history',
          );
        }
        return _FakeResponse.ok({'status': 'streaming'});
      },
    );
    addTearDown(gw.close);

    final sync = SessionSyncRepository(gatewayId: 'gw1', db: db, api: null);
    final realtime = GatewayRealtime(
      profile: gw.openProfile(),
      sessionSync: sync,
    );
    sync.bindRealtime(realtime);
    addTearDown(realtime.dispose);

    expect(await realtime.ensureLive(), isTrue);

    final result = await sync.sendMessage(
      sessionId: 'sess-1',
      input: 'edited message',
      truncateBeforeUserOrdinal: 2,
    );

    expect(gw.promptSubmitCalls, 2, reason: 'exactly one ordinal-free retry');
    expect(
      gw.promptSubmitParams[0].containsKey('truncate_before_user_ordinal'),
      isTrue,
    );
    expect(
      gw.promptSubmitParams[0]['confirm_truncate'],
      isTrue,
      reason: 'the gateway requires explicit confirmation for every rewind',
    );
    expect(
      gw.promptSubmitParams[1].containsKey('truncate_before_user_ordinal'),
      isFalse,
      reason: 'the retry must drop the ordinal entirely',
    );
    expect(result.queued, isFalse);
    expect(result.error, isNull);
    expect(
      await db.pendingOpsForGateway('gw1'),
      isEmpty,
      reason: 'a live gateway rejection must never enqueue to the outbox',
    );
  });

  test('stale-target 4018 that fails even after the ordinal-free retry '
      'surfaces a terminal error and never queues as offline', () async {
    final gw = await _FakeGateway.start(
      promptSubmitBehavior: (params, callIndex) => _FakeResponse.error(
        4018,
        'target user message is no longer in session history',
      ),
    );
    addTearDown(gw.close);

    final sync = SessionSyncRepository(gatewayId: 'gw2', db: db, api: null);
    final realtime = GatewayRealtime(
      profile: gw.openProfile(),
      sessionSync: sync,
    );
    sync.bindRealtime(realtime);
    addTearDown(realtime.dispose);

    expect(await realtime.ensureLive(), isTrue);

    final result = await sync.sendMessage(
      sessionId: 'sess-2',
      input: 'edited message',
      truncateBeforeUserOrdinal: 5,
    );

    expect(gw.promptSubmitCalls, 2, reason: 'still exactly one retry attempt');
    expect(
      result.queued,
      isFalse,
      reason: 'a permanent rejection is not offline',
    );
    expect(result.error, isNotNull);
    expect(
      await db.pendingOpsForGateway('gw2'),
      isEmpty,
      reason: 'never falls back to the outbox for a permanent rejection',
    );
    // Terminal error is persisted so it survives the next transcript pull.
    final local = await sync.loadMessagesLocal('sess-2');
    expect(
      local.any(
        (m) => (m.content ?? '').contains('no longer in session history'),
      ),
      isTrue,
    );
  });

  test('a non-rewind 4018 (e.g. oversized attachment) is terminal too, but '
      'is NOT retried (there is no ordinal to drop)', () async {
    final gw = await _FakeGateway.start(
      promptSubmitBehavior: (params, callIndex) => _FakeResponse.error(
        4018,
        'image too large (21000000 bytes; cap is 20 MB)',
      ),
    );
    addTearDown(gw.close);

    final sync = SessionSyncRepository(gatewayId: 'gw3', db: db, api: null);
    final realtime = GatewayRealtime(
      profile: gw.openProfile(),
      sessionSync: sync,
    );
    sync.bindRealtime(realtime);
    addTearDown(realtime.dispose);

    expect(await realtime.ensureLive(), isTrue);

    final result = await sync.sendMessage(
      sessionId: 'sess-3',
      input: 'a photo',
    );

    // No truncateBeforeUserOrdinal was supplied, so the stale-target retry
    // path never applies, and a terminal rejection breaks the connectivity
    // loop after its first attempt (a forced reconnect can't fix a
    // permanent rejection) — exactly one prompt.submit call total.
    expect(gw.promptSubmitCalls, 1);
    expect(result.queued, isFalse);
    expect(result.error, contains('image too large'));
    expect(await db.pendingOpsForGateway('gw3'), isEmpty);
  });

  test('a 4029 truncation validation failure is terminal and never queued as '
      'a connectivity failure', () async {
    final gw = await _FakeGateway.start(
      promptSubmitBehavior: (params, callIndex) => _FakeResponse.error(
        4029,
        'truncation parameters require confirm_truncate=true',
      ),
    );
    addTearDown(gw.close);

    final sync = SessionSyncRepository(gatewayId: 'gw4029', db: db, api: null);
    final realtime = GatewayRealtime(
      profile: gw.openProfile(),
      sessionSync: sync,
    );
    sync.bindRealtime(realtime);
    addTearDown(realtime.dispose);
    expect(await realtime.ensureLive(), isTrue);

    final result = await sync.sendMessage(
      sessionId: 'sess-4029',
      input: 'edited message',
      truncateBeforeUserOrdinal: 1,
    );

    expect(gw.promptSubmitCalls, 1);
    expect(gw.promptSubmitParams.single['confirm_truncate'], isTrue);
    expect(result.queued, isFalse);
    expect(result.error, contains('confirm_truncate'));
    expect(await db.pendingOpsForGateway('gw4029'), isEmpty);
  });

  test('a prompt.submit whose ack is lost to a dropped socket is NEVER '
      'resent, and never re-enqueued into the outbox', () async {
    // The frame reached the socket, so the gateway may already be running the
    // turn. The reconnect loop used to resend it here, which is how one tap
    // became two upstream provider calls (and, on a subscription-metered
    // provider like openai-codex, a self-inflicted 429).
    final gw = await _FakeGateway.start(
      promptSubmitBehavior: (params, callIndex) =>
          _FakeResponse.dropSocketWithoutReply(),
    );
    addTearDown(gw.close);

    final sync = SessionSyncRepository(gatewayId: 'gw4', db: db, api: null);
    final realtime = GatewayRealtime(
      profile: gw.openProfile(),
      sessionSync: sync,
    );
    sync.bindRealtime(realtime);
    addTearDown(realtime.dispose);

    expect(await realtime.ensureLive(), isTrue);

    final result = await sync.sendMessage(
      sessionId: 'sess-4',
      input: 'expensive prompt',
    );

    expect(
      gw.promptSubmitCalls,
      1,
      reason: 'delivery is unknown — resending can duplicate the turn',
    );
    expect(result.queued, isFalse);
    expect(result.error, contains('not resent'));
    expect(
      await db.pendingOpsForGateway('gw4'),
      isEmpty,
      reason: 'an outbox replay would be the same duplicate, later',
    );
  });

  group('delete a message', () {
    test('deleteMessageLocal removes the message and it stays gone after '
        'a simulated server resync repopulates the row', () async {
      final sync = SessionSyncRepository(gatewayId: 'gwd', db: db, api: null);
      final session = await sync.createSession(title: 'Chat');
      final sendResult = await sync.sendMessage(
        sessionId: session.id,
        input: 'oops, wrong thing',
      );
      final target = sendResult.messages.firstWhere((m) => m.isUser);

      final afterDelete = await sync.deleteMessageLocal(session.id, target.id);
      expect(afterDelete.any((m) => m.id == target.id), isFalse);
      expect(
        (await sync.loadMessagesLocal(
          session.id,
        )).any((m) => m.id == target.id),
        isFalse,
      );

      // The gateway still has its own copy — simulate a later pull bringing
      // the row back into the local cache the way `replaceMessages` would.
      await db.upsertMessage(
        CachedMessagesCompanion.insert(
          gatewayId: 'gwd',
          sessionId: session.id,
          id: target.id,
          role: 'user',
          content: const Value('oops, wrong thing'),
          sortIndex: const Value(0),
          syncStatus: const Value('synced'),
        ),
      );

      final local = await sync.loadMessagesLocal(session.id);
      expect(
        local.any((m) => m.id == target.id),
        isFalse,
        reason: 'the tombstone must keep it filtered out even after resync',
      );
    });
  });
}

typedef _PromptSubmitBehavior =
    _FakeResponse Function(Map<String, dynamic> params, int callIndex);

class _FakeResponse {
  _FakeResponse.ok(this.result) : error = null, dropSocket = false;
  _FakeResponse.error(int code, String message)
    : result = null,
      dropSocket = false,
      error = {'code': code, 'message': message};

  /// Accept the frame, then kill the connection without ever answering —
  /// the gateway may or may not have started the turn. Reproduces the
  /// ambiguous `prompt.submit` the client must never resend.
  _FakeResponse.dropSocketWithoutReply()
    : result = null,
      error = null,
      dropSocket = true;

  final Map<String, dynamic>? result;
  final Map<String, dynamic>? error;
  final bool dropSocket;
}

/// A minimal real WebSocket server standing in for `tui_gateway`'s
/// `/api/ws` — exercises [GatewayWsClient] / [GatewayRealtime] exactly as
/// written, no fakes at that layer.
class _FakeGateway {
  _FakeGateway(this.server, this._promptSubmitBehavior);

  final HttpServer server;
  final _PromptSubmitBehavior _promptSubmitBehavior;
  WebSocket? _socket;

  int promptSubmitCalls = 0;
  final List<Map<String, dynamic>> promptSubmitParams = [];

  static Future<_FakeGateway> start({
    required _PromptSubmitBehavior promptSubmitBehavior,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final gw = _FakeGateway(server, promptSubmitBehavior);
    server.listen((req) async {
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        final ws = await WebSocketTransformer.upgrade(req);
        gw._socket = ws;
        ws.listen(gw._onMessage);
      } else {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
      }
    });
    return gw;
  }

  ConnectionProfile openProfile() => ConnectionProfile(
    id: 'test-gw',
    baseUrl: 'http://127.0.0.1:${server.port}',
    authMode: 'open',
  );

  void _onMessage(dynamic raw) {
    final map = jsonDecode(raw as String) as Map<String, dynamic>;
    final id = map['id'];
    final method = map['method'] as String?;
    final params =
        (map['params'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    if (method == 'session.list') {
      _reply(id, result: {'sessions': []});
      return;
    }
    if (method == 'session.resume') {
      _reply(id, result: {'session_id': params['session_id']});
      return;
    }
    if (method == 'prompt.submit') {
      promptSubmitCalls++;
      promptSubmitParams.add(params);
      final resp = _promptSubmitBehavior(params, promptSubmitCalls);
      if (resp.dropSocket) {
        unawaited(_socket?.close() ?? Future<void>.value());
        return;
      }
      if (resp.error != null) {
        _reply(id, error: resp.error);
        return;
      }
      _reply(id, result: resp.result);
      // Complete the turn immediately so the client's turnDone future
      // resolves instead of waiting out the (real) 30-minute safety timeout.
      final sid = params['session_id'];
      Future.microtask(() {
        _socket?.add(
          jsonEncode({
            'method': 'event',
            'params': {
              'type': 'message.complete',
              'session_id': sid,
              'text': 'ok',
            },
          }),
        );
      });
      return;
    }
    // Anything else (interrupt, model pin, …): ack with an empty result so
    // the client's best-effort calls don't hang.
    _reply(id, result: {});
  }

  void _reply(
    dynamic id, {
    Map<String, dynamic>? result,
    Map<String, dynamic>? error,
  }) {
    final socket = _socket;
    if (socket == null) return;
    socket.add(
      jsonEncode({
        'id': id,
        if (error != null) 'error': error else 'result': result ?? {},
      }),
    );
  }

  Future<void> close() async {
    await _socket?.close();
    await server.close(force: true);
  }
}
