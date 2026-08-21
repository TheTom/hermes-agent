// Integration-style tests for the demo gateway (`lib/core/demo/`).
//
// These boot a *real* `DemoGatewayServer` on loopback and drive it with the
// app's own network clients (`GatewayAuthClient`, `DashboardClient`,
// `GatewayWsClient`) wherever possible — the point of wave 1 is that the
// real client code never has to know it's talking to a fake gateway, so the
// strongest test is exercising it with that exact code.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_mobile/core/demo/demo_gateway_server.dart';
import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/network/dashboard_client.dart';
import 'package:hermes_mobile/core/network/gateway_auth.dart';
import 'package:hermes_mobile/core/network/gateway_ws_client.dart';

/// `flutter_test`'s `TestWidgetsFlutterBinding` fakes every `HttpClient`
/// (including the one `WebSocket.connect` builds under the hood) with one
/// that always returns 400, to keep ordinary widget tests network-free. This
/// suite intentionally talks to a real (loopback) server, so every test body
/// runs inside a zone with this override installed instead — an
/// [HttpOverrides] subclass that overrides nothing falls through to
/// [HttpOverrides]'s own default `createHttpClient`, which builds the
/// genuine platform `HttpClient` (see `flutter_test`'s `_MockHttpOverrides`
/// doc comment: "If another HttpClient is provided using
/// HttpOverrides.runZoned, that will take precedence over this provider").
class _RealHttpOverrides extends HttpOverrides {}

Future<void> _withRealHttp(Future<void> Function() body) {
  return HttpOverrides.runWithHttpOverrides(body, _RealHttpOverrides());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // GatewayAuthClient.persistentJar() needs an app-support directory —
  // point it at the test temp dir (same pattern as session_sync_test.dart).
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => Directory.systemTemp.path,
      );

  // The persistent cookie jar mirrors into flutter_secure_storage. Fake the
  // platform channel with a simple in-memory map so login cookies actually
  // round-trip the way they do on device.
  final secureValues = <String, String>{};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (call) async {
          final args = call.arguments;
          final key = args is Map ? args['key'] as String? : null;
          switch (call.method) {
            case 'read':
              return key == null ? null : secureValues[key];
            case 'write':
              if (key != null) {
                secureValues[key] = (args as Map)['value'] as String;
              }
              return null;
            case 'delete':
              if (key != null) secureValues.remove(key);
              return null;
            case 'deleteAll':
              secureValues.clear();
              return null;
            case 'containsKey':
              return key != null && secureValues.containsKey(key);
            case 'readAll':
              return secureValues;
            default:
              return null;
          }
        },
      );

  late DemoGatewayServer server;
  late Uri baseUrl;

  setUp(() async {
    // The real app always uses `DemoAgentScript`'s default ~8-15s-per-turn
    // pacing (see its doc comment) so a reviewer actually perceives
    // streaming. That would make every WS test here slow, and the
    // interrupt test specifically wants a real (if short) time window to
    // land `session.interrupt` inside — so tests run the demo gateway at a
    // fraction of real speed rather than at the default.
    server = DemoGatewayServer(demoSpeedFactor: 0.15);
    baseUrl = await server.start();
  });

  tearDown(() async {
    await server.stop();
  });

  /// Logs in via a fresh persistent cookie jar scoped to [profileId] — the
  /// same jar `DashboardClient`/`GatewayRealtime` read for that profile —
  /// and returns an authenticated [GatewayAuthClient] on it.
  Future<GatewayAuthClient> loginAs(String profileId) async {
    final jar = await GatewayAuthClient.persistentJar(profileId);
    final auth = GatewayAuthClient(baseUrl: baseUrl.toString(), cookieJar: jar);
    await auth.passwordLogin(
      provider: 'demo',
      username: demoUsername,
      password: demoPassword,
    );
    return auth;
  }

  test('start() is idempotent while running', () async {
    final again = await server.start();
    expect(again, baseUrl);
  });

  test(
    'probe(): reachable, session auth, one password provider',
    () => _withRealHttp(() async {
      final probe = await GatewayAuthClient.probe(baseUrl.toString());
      expect(probe.reachable, isTrue);
      expect(probe.authMode, GatewayAuthMode.session);
      expect(probe.passwordProviders, isNotEmpty);
      expect(probe.isPasswordGateway, isTrue);
    }),
  );

  test(
    'probe(): explains reverse-proxy Host rejection',
    () => _withRealHttp(() async {
      final rejecting = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      rejecting.listen((request) async {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'detail':
                  'Invalid Host header. Dashboard requests must use the hostname the server was bound to.',
            }),
          );
        await request.response.close();
      });
      addTearDown(() => rejecting.close(force: true));

      final probe = await GatewayAuthClient.probe(
        'http://${rejecting.address.address}:${rejecting.port}',
      );

      expect(probe.reachable, isFalse);
      expect(probe.error, contains('HTTP 400 Invalid Host'));
      expect(probe.error, contains('Tailscale/LAN interface'));
    }),
  );

  test(
    'passwordLogin: demo/demo succeeds, anything else 401s',
    () => _withRealHttp(() async {
      final wrong = GatewayAuthClient(baseUrl: baseUrl.toString());
      await expectLater(
        wrong.passwordLogin(
          provider: 'demo',
          username: 'someone-else',
          password: 'wrong',
        ),
        throwsA(isA<GatewayAuthException>()),
      );
      expect(await wrong.hasSessionCookie(), isFalse);

      final right = GatewayAuthClient(baseUrl: baseUrl.toString());
      await right.passwordLogin(
        provider: 'demo',
        username: demoUsername.toUpperCase(), // case-insensitive username
        password: demoPassword,
      );
      expect(await right.hasSessionCookie(), isTrue);
    }),
  );

  test(
    'mintWsTicket() returns a ticket after login',
    () => _withRealHttp(() async {
      final auth = GatewayAuthClient(baseUrl: baseUrl.toString());
      await auth.passwordLogin(
        provider: 'demo',
        username: demoUsername,
        password: demoPassword,
      );
      final ticket = await auth.mintWsTicket();
      expect(ticket, isNotEmpty);
    }),
  );

  test(
    'DashboardClient sees seeded sessions, messages, skills, commands, '
    'cron jobs, and model options',
    () => _withRealHttp(() async {
      final profile = ConnectionProfile(
        id: 'demo-dashboard-${DateTime.now().microsecondsSinceEpoch}',
        baseUrl: baseUrl.toString(),
      );
      await loginAs(profile.id);

      final dashboard = DashboardClient(profile: profile);

      final sessions = await dashboard.listSessions();
      expect(sessions, isNotEmpty);
      // Four seeded fixture sessions — the "API latency review" session is
      // deliberately excluded from the seeded set while the artifact viewer
      // it demonstrates is paused for v1 (see kArtifactViewerEnabled).
      expect(sessions.length, 4);

      final messages = await dashboard.listMessages(sessions.first.id);
      expect(messages, isNotEmpty);

      final skills = await dashboard.listSkills();
      expect(skills, isNotEmpty);

      final commands = await dashboard.listCommands();
      expect(commands, isNotEmpty);

      final jobs = await dashboard.listCronJobs();
      expect(jobs, isNotEmpty);

      final options = await dashboard.listModelOptions();
      expect(options.providers, isNotEmpty);
      expect(options.asFlatModels(), isNotEmpty);
    }),
  );

  test(
    'unauthenticated requests to gated routes are rejected',
    () => _withRealHttp(() async {
      final client = HttpClient();
      addTearDown(client.close);
      final req = await client.getUrl(baseUrl.replace(path: '/api/sessions'));
      final res = await req.close();
      expect(res.statusCode, 401);
      await res.drain<void>();
    }),
  );

  test(
    'WebSocket: session.list sees fixtures; create + prompt.submit streams '
    'a full turn ending in message.complete with non-empty text',
    () => _withRealHttp(() async {
      final auth = GatewayAuthClient(baseUrl: baseUrl.toString());
      await auth.passwordLogin(
        provider: 'demo',
        username: demoUsername,
        password: demoPassword,
      );
      final ticket = await auth.mintWsTicket();
      final wsUrl = GatewayWsClient.buildWsUrl(
        baseUrl.toString(),
        ticket: ticket,
      );

      final client = GatewayWsClient();
      addTearDown(client.dispose);
      await client.connect(wsUrl);
      expect(client.isOpen, isTrue);

      final listed = await client.request('session.list', {'limit': 100});
      // Four seeded fixture sessions — see the count assertion above for why
      // it isn't five.
      expect((listed['sessions'] as List), hasLength(4));

      final created = await client.request('session.create', {
        'title': 'WS integration test',
      });
      final sessionId = created['session_id'] as String;
      expect(sessionId, isNotEmpty);

      final seenTypes = <String>[];
      final completion = Completer<Map<String, dynamic>>();
      final sub = client.events.listen((event) {
        if (event.sessionId != sessionId) return;
        seenTypes.add(event.type);
        if (event.type == 'message.complete' && !completion.isCompleted) {
          completion.complete(
            (event.payload['payload'] as Map).cast<String, dynamic>(),
          );
        }
      });
      addTearDown(sub.cancel);

      await client.request('prompt.submit', {
        'session_id': sessionId,
        'text': 'please search for the latest news',
      });

      final finalPayload = await completion.future.timeout(
        const Duration(seconds: 10),
      );
      expect('${finalPayload['text']}', isNotEmpty);
      expect(seenTypes, contains('reasoning.delta'));
      expect(seenTypes, contains('tool.start'));
      expect(seenTypes, contains('tool.complete'));
      expect(seenTypes, contains('message.delta'));

      // The tool call is not just a transient status line — it must be
      // persisted into the transcript as a `role: tool` message (the app
      // renders this permanently via `message.toolName`, see
      // `session_chat_screen.dart`), the same way a real gateway would.
      final profile = ConnectionProfile(
        id: 'demo-tool-message-${DateTime.now().microsecondsSinceEpoch}',
        baseUrl: baseUrl.toString(),
      );
      await loginAs(profile.id);
      final dashboard = DashboardClient(profile: profile);
      final messages = await dashboard.listMessages(sessionId);
      final toolMessage = messages.where((m) => m.isTool).firstOrNull;
      expect(toolMessage, isNotNull);
      expect(toolMessage!.toolName, 'web_search');
      expect(toolMessage.content, isNotEmpty);

      // The completed turn is now in the session's transcript.
      final messagesResult = await client.request('session.resume', {
        'session_id': sessionId,
      });
      expect(messagesResult['session_id'], sessionId);
    }),
  );

  test(
    'session.interrupt stops a turn mid-stream',
    () => _withRealHttp(() async {
      final auth = GatewayAuthClient(baseUrl: baseUrl.toString());
      await auth.passwordLogin(
        provider: 'demo',
        username: demoUsername,
        password: demoPassword,
      );
      final ticket = await auth.mintWsTicket();
      final wsUrl = GatewayWsClient.buildWsUrl(
        baseUrl.toString(),
        ticket: ticket,
      );

      final client = GatewayWsClient();
      addTearDown(client.dispose);
      await client.connect(wsUrl);

      final created = await client.request('session.create', {
        'title': 'Interrupt test',
      });
      final sessionId = created['session_id'] as String;

      var sawDelta = false;
      var sawComplete = false;
      final interrupted = Completer<void>();
      final sub = client.events.listen((event) {
        if (event.sessionId != sessionId) return;
        if (event.type == 'message.delta') sawDelta = true;
        if (event.type == 'message.complete') sawComplete = true;
        final inner = event.payload['payload'];
        if (event.type == 'status.update' &&
            inner is Map &&
            inner['kind'] == 'interrupted' &&
            !interrupted.isCompleted) {
          interrupted.complete();
        }
      });
      addTearDown(sub.cancel);

      await client.request('prompt.submit', {
        'session_id': sessionId,
        'text': 'tell me about a code bug and how you would fix it',
      });

      // Let the turn get into the token stream, then cut it off. At the
      // 0.15 test speed factor this "code bug" turn's reasoning + tool
      // phase (`DemoAgentScript.plan`'s prefix before any `message.delta`)
      // takes ~728ms and the whole turn ~1334ms — 950ms lands comfortably
      // inside the token stream without waiting for it to finish.
      await Future<void>.delayed(const Duration(milliseconds: 950));
      await client.request('session.interrupt', {'session_id': sessionId});

      await interrupted.future.timeout(const Duration(seconds: 5));
      // Give any already-scheduled event a moment to land before asserting
      // the turn never reached a normal completion.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(sawDelta, isTrue);
      expect(sawComplete, isFalse);
    }),
  );

  test(
    'mutations persist: rename a session, pause a job',
    () => _withRealHttp(() async {
      final auth = GatewayAuthClient(baseUrl: baseUrl.toString());
      await auth.passwordLogin(
        provider: 'demo',
        username: demoUsername,
        password: demoPassword,
      );
      final ticket = await auth.mintWsTicket();
      final wsUrl = GatewayWsClient.buildWsUrl(
        baseUrl.toString(),
        ticket: ticket,
      );

      final client = GatewayWsClient();
      addTearDown(client.dispose);
      await client.connect(wsUrl);

      final before = await client.request('session.list', {'limit': 100});
      final firstId = (before['sessions'] as List).first['id'] as String;

      await client.request('session.title', {
        'session_id': firstId,
        'title': 'Renamed by test',
      });
      final after = await client.request('session.list', {'limit': 100});
      final renamed = (after['sessions'] as List).cast<Map>().firstWhere(
        (s) => s['id'] == firstId,
      );
      expect(renamed['title'], 'Renamed by test');

      final profile = ConnectionProfile(
        id: 'demo-jobs-${DateTime.now().microsecondsSinceEpoch}',
        baseUrl: baseUrl.toString(),
      );
      await loginAs(profile.id);
      final dashboard = DashboardClient(profile: profile);

      final jobsBefore = await dashboard.listCronJobs();
      final activeJob = jobsBefore.firstWhere((j) => j.enabled == true);
      expect(activeJob.enabled, isTrue);

      await dashboard.pauseJob(activeJob.id);
      final jobsAfter = await dashboard.listCronJobs();
      final paused = jobsAfter.firstWhere((j) => j.id == activeJob.id);
      expect(paused.enabled, isFalse);
    }),
  );

  test('stop() releases the port', () async {
    final port = baseUrl.port;
    await server.stop();
    expect(server.isRunning, isFalse);
    expect(server.baseUri, isNull);

    var refused = false;
    try {
      final socket = await Socket.connect(
        '127.0.0.1',
        port,
        timeout: const Duration(seconds: 2),
      );
      await socket.close();
    } catch (_) {
      refused = true;
    }
    expect(refused, isTrue);
  });
}
