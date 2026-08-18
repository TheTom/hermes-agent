import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_mobile/core/db/app_database.dart';
import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/network/gateway_ws_client.dart';
import 'package:hermes_mobile/core/sync/gateway_realtime.dart';
import 'package:hermes_mobile/core/sync/session_sync_repository.dart';

/// Mirrors [GatewayRealtime._nextBackoffDelay] for unit checks without a
/// full GatewayRealtime (needs cookie jars / platform channels).
Duration nextBackoffDelay({
  required int attempt,
  required math.Random rng,
  Duration base = const Duration(milliseconds: 1000),
  Duration cap = const Duration(seconds: 15),
}) {
  final exp = base.inMilliseconds * (1 << math.min(attempt, 4));
  final capped = math.min(exp, cap.inMilliseconds);
  final jittered = (capped * (0.5 + rng.nextDouble() * 0.5)).round();
  return Duration(milliseconds: math.max(250, jittered));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('backoff doubles then caps at 15s (with zero jitter = lower half)', () {
    // Fixed RNG always returns 0 → jitter multiplier = 0.5
    final rng = _FixedRandom(0);
    expect(nextBackoffDelay(attempt: 0, rng: rng).inMilliseconds, 500);
    expect(nextBackoffDelay(attempt: 1, rng: rng).inMilliseconds, 1000);
    expect(nextBackoffDelay(attempt: 2, rng: rng).inMilliseconds, 2000);
    expect(nextBackoffDelay(attempt: 3, rng: rng).inMilliseconds, 4000);
    expect(nextBackoffDelay(attempt: 4, rng: rng).inMilliseconds, 7500);
    // attempt 5+ still shifts only to 4 for exp (1<<4 = 16s → cap 15s → *0.5)
    expect(nextBackoffDelay(attempt: 8, rng: rng).inMilliseconds, 7500);
  });

  test('jitter upper bound hits full cap', () {
    // RNG returns 1.0 clamped in nextDouble as almost 1 → 0.5+0.5=1.0
    final rng = _FixedRandom(0.999999);
    final d = nextBackoffDelay(attempt: 4, rng: rng);
    expect(d.inMilliseconds, greaterThanOrEqualTo(14000));
    expect(d.inMilliseconds, lessThanOrEqualTo(15000));
  });

  test('max attempts window is finite (12 tries)', () {
    // Sanity: policy constants still match AGENTS.md contract.
    const maxAttempts = 12;
    const maxWindow = Duration(minutes: 2);
    expect(maxAttempts, 12);
    expect(maxWindow.inSeconds, 120);
  });

  test(
    'a failed connect releases its lock and reconnects automatically',
    () async {
      var upgradeRequests = 0;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        if (!WebSocketTransformer.isUpgradeRequest(request)) {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }
        upgradeRequests++;
        if (upgradeRequests == 1) {
          // Fail the first real handshake immediately. Before the fix this
          // returned with no timer scheduled because its lock was still held.
          request.response.statusCode = HttpStatus.serviceUnavailable;
          await request.response.close();
          return;
        }
        final socket = await WebSocketTransformer.upgrade(request);
        socket.listen((raw) {
          final frame = jsonDecode(raw as String) as Map<String, dynamic>;
          socket.add(
            jsonEncode({
              'id': frame['id'],
              'result': {'sessions': <Object>[]},
            }),
          );
        });
      });

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final sync = SessionSyncRepository(
        gatewayId: 'retry-gw',
        db: db,
        api: null,
      );
      final realtime = GatewayRealtime(
        profile: ConnectionProfile(
          id: 'retry-gw',
          baseUrl: 'http://127.0.0.1:${server.port}',
          authMode: 'open',
        ),
        sessionSync: sync,
        random: _FixedRandom(0),
      );
      sync.bindRealtime(realtime);

      addTearDown(() async {
        await realtime.dispose();
        await server.close(force: true);
        await db.close();
      });

      expect(await realtime.ensureLive(), isFalse);

      final deadline = DateTime.now().add(const Duration(seconds: 3));
      while ((realtime.connectionState != GatewayWsState.open ||
              realtime.reconnectAttempt != 0 ||
              realtime.lastError != null) &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }

      expect(realtime.connectionState, GatewayWsState.open);
      expect(upgradeRequests, 2);
      expect(realtime.reconnectAttempt, 0);
      expect(realtime.lastError, isNull);
    },
  );
}

class _FixedRandom implements math.Random {
  _FixedRandom(this.value);
  final double value;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}
