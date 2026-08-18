import 'dart:async';

import 'package:flutter/foundation.dart';

/// Serializes every secure-storage platform-channel call app-wide and
/// exposes when the channel is quiet.
///
/// Why this exists: spawning Workmanager's headless engine while a
/// flutter_secure_storage call is in flight can wedge the platform channel
/// on iOS — the in-flight call never completes (observed as a permanent
/// boot spinner with a full disk, and as ~30s cold starts on device when
/// a logged-in profile does a burst of keychain ops at launch: book read,
/// cookie reads, mirror re-seed). Two defenses:
///
/// 1. All keychain ops run strictly one-at-a-time through [run], so an
///    overlap between two storage calls can never happen.
/// 2. [whenIdle] completes only when no op is queued or in flight, so
///    main.dart can hold heavyweight plugin init (Workmanager's second
///    engine) until the boot-time keychain burst has drained.
class SecureStorageGate {
  SecureStorageGate._();

  /// A platform-channel Keychain call must never block every future secure
  /// storage operation for the lifetime of the process. iOS occasionally
  /// strands a call while switching execution between the foreground app and
  /// Workmanager's headless engine. Let that individual call fail so the
  /// serialized queue — and the gateway reconnect loop waiting behind it —
  /// can continue.
  static const operationTimeout = Duration(seconds: 15);

  static Future<void> _tail = Future<void>.value();
  static int _pending = 0;

  /// True while any storage op is queued or executing.
  static bool get busy => _pending > 0;

  /// Run [op] after all previously queued ops complete. Errors from earlier
  /// ops never poison the queue; each caller still sees its own op's error.
  static Future<T> run<T>(Future<T> Function() op, {Duration? timeout}) {
    _pending += 1;
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        final deadline =
            timeout ??
            (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
                ? operationTimeout
                : null);
        final pending = Future<T>.sync(op);
        completer.complete(
          await (deadline == null
              ? pending
              : pending.timeout(
                  deadline,
                  onTimeout: () => throw TimeoutException(
                    'Secure storage did not respond within '
                    '${deadline.inSeconds}s',
                    deadline,
                  ),
                )),
        );
      } catch (e, st) {
        completer.completeError(e, st);
      } finally {
        _pending -= 1;
      }
    });
    return completer.future;
  }

  /// Completes when the queue is fully drained. If ops keep arriving this
  /// keeps waiting, so callers should combine it with a timeout.
  static Future<void> whenIdle() async {
    while (busy) {
      await _tail.catchError((_) {});
      // Yield so ops enqueued by just-finished ops are observed.
      await Future<void>.delayed(Duration.zero);
    }
  }
}
