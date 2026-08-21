import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notifications for Hermes results (chat turns, cron jobs, outbox).
///
/// Host agent still does the work; the phone surfaces outcomes when a turn
/// completes or background sync discovers them.
///
/// Unrelated to WebSocket "live" status — notifications only need OS permission.
class ResultNotifier {
  ResultNotifier({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final instance = ResultNotifier();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool? _permissionGranted;

  /// Dedupe rapid double-fires (WS complete + send finalize).
  final _recentSessionNotifies = <String, DateTime>{};

  static const androidJobsChannel = AndroidNotificationDetails(
    'hermes_jobs',
    'Hermes Jobs',
    channelDescription: 'Cron and scheduled job updates from your Hermes agent',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );

  static const androidResultsChannel = AndroidNotificationDetails(
    'hermes_results',
    'Hermes Results',
    channelDescription: 'Agent replies and synced session results',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  static const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    presentBanner: true,
    presentList: true,
    interruptionLevel: InterruptionLevel.active,
  );

  bool get isReady => _ready;

  /// `null` = not checked yet; `true`/`false` after [refreshPermissionStatus].
  bool? get permissionGranted => _permissionGranted;

  Future<void> init({bool requestPermission = true}) async {
    if (_ready && !requestPermission) {
      await refreshPermissionStatus();
      return;
    }
    try {
      const android = AndroidInitializationSettings('ic_notification');
      // Do NOT request on init settings — we request explicitly so Settings
      // can show a clear test path (and avoid double prompts).
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onTap,
      );

      if (requestPermission) {
        await this.requestPermission();
      } else {
        await refreshPermissionStatus();
      }

      _ready = true;
    } catch (e, st) {
      debugPrint('ResultNotifier.init failed: $e\n$st');
    }
  }

  void _onTap(NotificationResponse response) {
    debugPrint('ResultNotifier tap payload=${response.payload}');
  }

  /// Read current OS permission without prompting.
  Future<bool> refreshPermissionStatus() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final ok = await android.areNotificationsEnabled();
        _permissionGranted = ok ?? true;
        return _permissionGranted!;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final opts = await ios.checkPermissions();
        if (opts != null) {
          _permissionGranted =
              opts.isEnabled ||
              opts.isProvisionalEnabled ||
              opts.isAlertEnabled;
        } else {
          // Unknown — don't claim denied.
          _permissionGranted ??= true;
        }
        return _permissionGranted ?? true;
      }

      _permissionGranted ??= true;
      return _permissionGranted!;
    } catch (e) {
      debugPrint('ResultNotifier.refreshPermissionStatus failed: $e');
      // Don't flip to denied on check errors.
      return _permissionGranted ?? true;
    }
  }

  /// Explicit user-facing permission request (Settings → Notifications).
  Future<bool> requestPermission() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final ok = await android.requestNotificationsPermission();
        // null = not required / already handled
        _permissionGranted = ok ?? true;
        return _permissionGranted!;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        // Prompt (no-op if already decided), then trust checkPermissions.
        await ios.requestPermissions(alert: true, badge: true, sound: true);
        // Critical: requestPermissions can return null/false even when already
        // authorized in some iOS versions — always re-check.
        return await refreshPermissionStatus();
      }

      _permissionGranted = true;
      return true;
    } catch (e) {
      debugPrint('ResultNotifier.requestPermission failed: $e');
      // Fall through to check — don't hard-deny on exception.
      return refreshPermissionStatus();
    }
  }

  Future<void> showSessionResult({
    required String sessionId,
    required String title,
    required String body,
  }) async {
    await init(requestPermission: false);
    final now = DateTime.now();
    for (final e in _recentSessionNotifies.entries) {
      if (now.difference(e.value) < const Duration(seconds: 20) &&
          (e.key == sessionId ||
              sessionId.startsWith(e.key) ||
              e.key.startsWith(sessionId))) {
        debugPrint('ResultNotifier skip duplicate session=$sessionId');
        return;
      }
    }
    for (final t in _recentSessionNotifies.values) {
      if (now.difference(t) < const Duration(seconds: 3)) {
        debugPrint('ResultNotifier skip burst session=$sessionId');
        _recentSessionNotifies[sessionId] = now;
        return;
      }
    }
    _recentSessionNotifies[sessionId] = now;
    if (_recentSessionNotifies.length > 40) {
      final cutoff = now.subtract(const Duration(minutes: 5));
      _recentSessionNotifies.removeWhere((_, t) => t.isBefore(cutoff));
    }

    final id = sessionId.hashCode & 0x7fffffff;
    try {
      await _plugin.show(
        id == 0 ? 1 : id,
        title,
        body.isEmpty ? 'Agent finished' : body,
        const NotificationDetails(
          android: androidResultsChannel,
          iOS: iosDetails,
        ),
        payload: 'session:$sessionId',
      );
      debugPrint('ResultNotifier session notify ok id=$sessionId');
    } catch (e, st) {
      debugPrint('ResultNotifier.showSessionResult failed: $e\n$st');
    }
  }

  Future<void> showJobResult({
    required String jobId,
    required String title,
    required String body,
  }) async {
    await init(requestPermission: false);
    final id = (jobId.hashCode ^ 0x5f3759df) & 0x7fffffff;
    try {
      await _plugin.show(
        id == 0 ? 2 : id,
        title,
        body,
        const NotificationDetails(android: androidJobsChannel, iOS: iosDetails),
        payload: 'job:$jobId',
      );
      debugPrint('ResultNotifier job notify ok id=$jobId');
    } catch (e, st) {
      debugPrint('ResultNotifier.showJobResult failed: $e\n$st');
    }
  }

  Future<void> showSyncSummary({
    required String title,
    required String body,
  }) async {
    await init(requestPermission: false);
    try {
      await _plugin.show(
        900001,
        title,
        body,
        const NotificationDetails(
          android: androidResultsChannel,
          iOS: iosDetails,
        ),
      );
    } catch (e, st) {
      debugPrint('ResultNotifier.showSyncSummary failed: $e\n$st');
    }
  }

  /// Settings "Send test notification". Always attempts show after request.
  /// Returns a short status string for the snackbar.
  Future<String> showTest() async {
    await init(requestPermission: false);
    await requestPermission();
    try {
      await _plugin.show(
        900002,
        'Hermes Go',
        'Notifications are working. You will get alerts when tasks finish.',
        const NotificationDetails(
          android: androidResultsChannel,
          iOS: iosDetails,
        ),
      );
      _permissionGranted = true;
      return 'Test notification sent — check your lock screen / banners.';
    } catch (e, st) {
      debugPrint('ResultNotifier.showTest failed: $e\n$st');
      final allowed = await refreshPermissionStatus();
      if (!allowed) {
        return 'Notifications blocked. iOS Settings → Hermes Go → Notifications → Allow.';
      }
      return 'Could not show notification: $e';
    }
  }
}
