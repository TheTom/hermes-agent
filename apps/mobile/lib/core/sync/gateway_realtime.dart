import 'dart:async';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/network/connection_store.dart';
import 'package:hermes_mobile/core/network/gateway_auth.dart';
import 'package:hermes_mobile/core/network/gateway_ws_client.dart';
import 'package:hermes_mobile/core/services/app_lifecycle.dart';
import 'package:hermes_mobile/core/services/result_notifier.dart';
import 'package:hermes_mobile/core/sync/session_sync_repository.dart';
import 'package:hermes_mobile/core/sync/session_touch.dart';
import 'package:hermes_mobile/core/sync/watch_store.dart';

/// Live session feed — Desktop parity + mobile robustness.
///
/// Desktop keeps `/api/ws` open and applies push events. Mobile does the same
/// while foregrounded, with:
/// - single-flight connect + stable instance per gateway id (Riverpod holder)
/// - protocol pings (IOWebSocketChannel) to survive CF Tunnel idle (~100s)
/// - exponential backoff + jitter on drop (Desktop shape: 1s→15s)
/// - give-up after max attempts (manual Reconnect)
/// - zombie probe on resume / periodic liveness RPC
/// - force reconnect on network path change (Wi‑Fi↔cellular)
///
/// Workmanager poll is only a last-resort when the OS has killed the app.
class GatewayRealtime {
  GatewayRealtime({
    required this.profile,
    required SessionSyncRepository sessionSync,
    ConnectionStore? connectionStore,
    Object? restApi,

    /// Called when session cookies are dead (401). Must prompt interactive login.
    void Function(String message)? onNeedsReauth,
    math.Random? random,
  }) : // Public named parameters cannot use private field names.
       // ignore: prefer_initializing_formals
       _sessionSync = sessionSync,
       // ignore: prefer_initializing_formals
       _onNeedsReauth = onNeedsReauth,
       _rng = random ?? math.Random();

  final ConnectionProfile profile;
  SessionSyncRepository _sessionSync;
  final void Function(String message)? _onNeedsReauth;
  final math.Random _rng;

  final _client = GatewayWsClient();
  StreamSubscription<GatewayWsEvent>? _events;
  StreamSubscription<GatewayWsState>? _states;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _reconnect;
  Timer? _retryUiTicker;
  Timer? _eventRefreshDebounce;
  Timer? _pollTimer;
  Timer? _livenessTimer;

  /// Desktop `wantOpen` — auto-reconnect only while true.
  var _wantConnected = false;
  var _disposed = false;
  var _refreshing = false;
  var _foregrounded = true;
  var _livenessFailCount = 0;

  /// Suppress reconnect when we deliberately close (force remint / stop).
  var _suppressReconnect = false;
  DateTime? _lastHealthyAt;
  DateTime? _lastResumeProbeAt;
  Timer? _pathChangeDebounce;

  /// Serialize connect attempts (shell boot + Settings check + resume).
  Future<bool>? _connectLock;

  /// Failed connect attempts since last successful open (Desktop shape).
  var _reconnectAttempt = 0;
  var _gaveUp = false;
  DateTime? _reconnectWindowStarted;
  Duration? _nextRetryIn;
  DateTime? _nextRetryAt;
  List<ConnectivityResult>? _lastConnectivity;

  String? lastError;

  /// Optional pin ids so event-driven pulls don't drop pinned rows.
  List<String> Function()? _keepIds;

  final _sessionTouchController = StreamController<SessionTouch>.broadcast();
  final _stateTick = StreamController<void>.broadcast();
  final _workingSessionController = StreamController<Set<String>>.broadcast();
  final _workingSessionIds = <String>{};

  /// Fires when WS open/closed / reconnect policy changes (Settings UI).
  Stream<void> get stateChanges => _stateTick.stream;

  /// Cache was refreshed — UI should re-read sessions / open transcript.
  Stream<SessionTouch> get sessionTouches => _sessionTouchController.stream;

  /// Live session ids that are inside an actual agent turn. Unlike roster
  /// timestamps, this does not treat a recent system/model-change message as
  /// proof that a bot is still working.
  Set<String> get workingSessionIds => Set.unmodifiable(_workingSessionIds);
  Stream<Set<String>> get workingSessions => _workingSessionController.stream;

  GatewayWsState get connectionState => _client.state;

  /// True when the socket is open, or we had healthy WS traffic very recently
  /// (avoids Settings flashing "reconnecting" during a sub-second remint).
  bool get isLive {
    if (_client.isOpen) return true;
    final t = _lastHealthyAt;
    if (t == null || !_wantConnected || _gaveUp) return false;
    // Brief grace only — not a substitute for a real open socket.
    return DateTime.now().difference(t) < const Duration(seconds: 8) &&
        (_connectLock != null ||
            _client.state == GatewayWsState.connecting ||
            _reconnect != null);
  }

  bool get wantConnected => _wantConnected;
  bool get gaveUp => _gaveUp;
  int get reconnectAttempt => _reconnectAttempt;

  void markHealthy({bool notifyIfErrorCleared = true}) {
    _lastHealthyAt = DateTime.now();
    _livenessFailCount = 0;
    if (lastError != null) {
      lastError = null;
      if (notifyIfErrorCleared) _notifyState();
    }
  }

  /// Rich status for Settings / chrome (human label + machine fields).
  GatewayWsUiStatus get uiStatus {
    // Prefer "Live" whenever the socket is open OR we're mid-brief remint
    // after being healthy (isLive grace). Stops permanent "reconnecting" lies.
    if (_client.isOpen || isLive) {
      return const GatewayWsUiStatus(
        phase: GatewayWsUiPhase.live,
        label: 'Live',
      );
    }
    if (!_wantConnected) {
      return GatewayWsUiStatus(
        phase: GatewayWsUiPhase.stopped,
        label: 'Stopped',
        detail: lastError,
      );
    }
    if (_gaveUp) {
      return GatewayWsUiStatus(
        phase: GatewayWsUiPhase.gaveUp,
        label: 'Gave up — tap Reconnect',
        detail: lastError,
        attempt: _reconnectAttempt,
      );
    }
    if (_client.state == GatewayWsState.connecting || _connectLock != null) {
      return GatewayWsUiStatus(
        phase: GatewayWsUiPhase.connecting,
        label: _reconnectAttempt > 0
            ? 'Connecting… · attempt ${_reconnectAttempt + 1}'
            : 'Connecting…',
        detail: lastError,
        attempt: _reconnectAttempt,
      );
    }
    if (_reconnect != null && _nextRetryAt != null) {
      final secs = _nextRetryAt!.difference(DateTime.now()).inSeconds;
      final wait = secs < 1 ? 1 : secs;
      return GatewayWsUiStatus(
        phase: GatewayWsUiPhase.reconnecting,
        label: 'Reconnecting · attempt ${_reconnectAttempt + 1} · ${wait}s',
        detail: lastError,
        attempt: _reconnectAttempt,
        nextDelay: _nextRetryIn,
      );
    }
    return GatewayWsUiStatus(
      phase: GatewayWsUiPhase.offline,
      label: lastError != null && lastError!.isNotEmpty ? 'Offline' : 'Idle',
      detail: lastError,
      attempt: _reconnectAttempt,
    );
  }

  /// Push events (`message.delta`, `message.complete`, `tool.start`, …).
  Stream<GatewayWsEvent> get events => _client.events;

  /// How often to re-pull session list while connected + foregrounded.
  // WebSocket events are the primary update path. Keep a low-frequency safety
  // pull for missed gateway events without redownloading the session list
  // every few seconds on a phone.
  static const foregroundPollInterval = Duration(minutes: 1);

  /// App-level zombie probe while "open" (protocol ping alone can lie).
  /// Keep this gentle — a single slow session.list must not thrash the UI.
  static const livenessInterval = Duration(seconds: 45);
  static const livenessRpcTimeout = Duration(seconds: 12);
  static const livenessFailThreshold = 2;

  /// Desktop secondary backoff: 1s, 2s, 4s … capped at 15s.
  static const reconnectBase = Duration(milliseconds: 1000);
  static const reconnectCap = Duration(seconds: 15);
  static const maxReconnectAttempts = 12;
  static const maxReconnectWindow = Duration(minutes: 2);

  /// Includes cookie loading plus the ticket POST. Dio already bounds the
  /// network phases; this outer deadline also covers platform/plugin work
  /// before the request so `_connectLock` can never remain held forever.
  static const wsUrlResolutionTimeout = Duration(seconds: 35);

  /// Rebind session cache after Riverpod rebuilds the repository instance.
  void bindSessionSync(SessionSyncRepository sync) {
    _sessionSync = sync;
  }

  void bindKeepIds(List<String> Function()? keepIds) {
    _keepIds = keepIds;
  }

  /// JSON-RPC call on the live Desktop gateway socket.
  Future<Map<String, dynamic>> request(
    String method, [
    Map<String, dynamic>? params,
    Duration? timeout,
  ]) {
    return _client.requestWithTimeout(method, params, timeout);
  }

  /// Connect to dashboard/serve WebSocket (same as Desktop).
  Future<bool> start() async {
    _wantConnected = true;
    _gaveUp = false;
    _ensureConnectivityWatch();
    final ok = await _connectOnce();
    if (ok) {
      _startForegroundPoll();
      _startLivenessProbe();
    }
    return ok;
  }

  /// Ensure the Desktop WS is usable for chat.
  ///
  /// If [force] is true: tear down half-dead socket, reset give-up, remint ticket.
  /// Prefer [force]: false from Settings auto-check — force remint only when
  /// the user taps Reconnect or we detected a dead socket.
  Future<bool> ensureLive({bool force = false}) async {
    _wantConnected = true;
    _ensureConnectivityWatch();

    if (force) {
      _gaveUp = false;
      _reconnectAttempt = 0;
      _reconnectWindowStarted = null;
      _reconnect?.cancel();
      _reconnect = null;
      _nextRetryIn = null;
      _nextRetryAt = null;
      _retryUiTicker?.cancel();
      _retryUiTicker = null;
    }

    if (_gaveUp && !force) {
      lastError ??= 'Gave up reconnecting. Tap Reconnect.';
      _notifyState();
      return false;
    }

    // Already healthy — do not thrash (Settings open used to force remint).
    if (_client.isOpen && !force) {
      lastError = null;
      markHealthy();
      return true;
    }

    // Stuck mid-handshake with no in-flight lock → recover.
    final stuckConnecting =
        _client.state == GatewayWsState.connecting && _connectLock == null;
    if (force || stuckConnecting || _client.state == GatewayWsState.error) {
      _suppressReconnect = true;
      try {
        await _client.disconnect();
      } catch (_) {}
      _suppressReconnect = false;
    }

    if (_client.isOpen && !force) {
      lastError = null;
      markHealthy();
      return true;
    }

    final ok = await _connectOnce();
    if (ok) {
      markHealthy();
      _startForegroundPoll();
      _startLivenessProbe();
    }
    return ok;
  }

  /// App returned to foreground — iOS often parks the TCP socket as a zombie.
  ///
  /// Do **not** hard-probe on every Control Center / app-switch flicker; that
  /// was killing a live socket and leaving Settings on "reconnecting".
  Future<bool> onAppResumed() async {
    _foregrounded = true;
    if (!_wantConnected || _disposed) return false;
    _ensureConnectivityWatch();

    final now = DateTime.now();
    final last = _lastResumeProbeAt;
    if (last != null && now.difference(last) < const Duration(seconds: 12)) {
      // Recent resume already handled — just refresh caches if open.
      if (_client.isOpen) {
        unawaited(refreshCaches(reason: 'resume'));
        return true;
      }
      return ensureLive(force: false);
    }
    _lastResumeProbeAt = now;

    if (_client.isOpen) {
      // Soft probe only — never disconnect on a single timeout here.
      final alive = await probeLiveness(disconnectOnFail: false);
      if (alive) {
        markHealthy();
        unawaited(refreshCaches(reason: 'resume'));
        return true;
      }
      if (_livenessFailCount >= livenessFailThreshold) {
        debugPrint('GatewayRealtime: zombie on resume — force reconnect');
        return ensureLive(force: true);
      }
      // One failure: leave socket up, report live grace via isLive if healthy.
      return _client.isOpen;
    }

    // Not open: reset give-up and reconnect without redundant force if possible.
    _gaveUp = false;
    return ensureLive(force: false);
  }

  void onAppPaused() {
    _foregrounded = false;
    // Don't tear down deliberately — OS may keep us briefly. Zombie check on resume.
  }

  /// Wi‑Fi ↔ cellular / airplane mode. TCP often looks open but is dead.
  ///
  /// iOS fires noisy path updates (wifi→wifi+other, vpn flaps). Never force
  /// reconnect on every blip — that stuck Settings on "reconnecting" while
  /// chat was still fine between thrash cycles.
  Future<void> onNetworkPathChanged(List<ConnectivityResult> results) async {
    if (_disposed || !_wantConnected || !_foregrounded) return;

    final normalized = _normalizeConnectivity(results);
    final prev = _lastConnectivity;
    _lastConnectivity = normalized;

    // First sample only — no reconnect storm at boot.
    if (prev == null) return;

    if (_sameConnectivity(prev, normalized)) return;

    final offline = _isOffline(normalized);
    if (offline) {
      lastError = 'Network offline';
      _notifyState();
      return;
    }

    final wasOffline = _isOffline(prev);
    // Still online, just a different interface set — soft check, don't kill socket.
    if (!wasOffline && _client.isOpen) {
      debugPrint(
        'GatewayRealtime: path change $prev → $normalized (still online, soft probe)',
      );
      _pathChangeDebounce?.cancel();
      _pathChangeDebounce = Timer(const Duration(seconds: 2), () {
        unawaited(() async {
          if (_disposed || !_wantConnected) return;
          if (!_client.isOpen) {
            await ensureLive(force: true);
            return;
          }
          final ok = await probeLiveness(disconnectOnFail: false);
          if (!ok) {
            debugPrint('GatewayRealtime: soft probe failed after path change');
            await ensureLive(force: true);
          }
        }());
      });
      return;
    }

    // Came back online from offline — reconnect (debounced).
    debugPrint('GatewayRealtime: path change $prev → $normalized — reconnect');
    _pathChangeDebounce?.cancel();
    _pathChangeDebounce = Timer(const Duration(seconds: 1), () {
      unawaited(ensureLive(force: !_client.isOpen));
    });
  }

  bool _isOffline(List<ConnectivityResult> results) {
    return results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);
  }

  /// Cheap RPC to verify the socket is still usable (not a zombie).
  ///
  /// By default does **not** tear down the socket on a single failure (slow
  /// list during a long tool turn used to kill the WS and show reconnecting).
  Future<bool> probeLiveness({bool disconnectOnFail = false}) async {
    if (!_client.isOpen) return false;
    try {
      await _client.requestWithTimeout('session.list', {
        'limit': 1,
      }, livenessRpcTimeout);
      _livenessFailCount = 0;
      if (lastError != null && lastError!.toLowerCase().contains('liveness')) {
        lastError = null;
        _notifyState();
      }
      return true;
    } catch (e) {
      debugPrint('GatewayRealtime liveness failed: $e');
      _livenessFailCount++;
      if (disconnectOnFail || _livenessFailCount >= livenessFailThreshold) {
        lastError = 'Liveness probe failed: $e';
        try {
          await _client.disconnect();
        } catch (_) {}
        _notifyState();
      }
      return false;
    }
  }

  Future<void> stop() async {
    _wantConnected = false;
    _gaveUp = false;
    _reconnectAttempt = 0;
    _reconnectWindowStarted = null;
    _nextRetryIn = null;
    _nextRetryAt = null;
    _reconnect?.cancel();
    _reconnect = null;
    _retryUiTicker?.cancel();
    _retryUiTicker = null;
    _pathChangeDebounce?.cancel();
    _pathChangeDebounce = null;
    _eventRefreshDebounce?.cancel();
    _pollTimer?.cancel();
    _pollTimer = null;
    _livenessTimer?.cancel();
    _livenessTimer = null;
    _livenessFailCount = 0;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await _events?.cancel();
    await _states?.cancel();
    await _client.disconnect();
    _clearWorkingSessions();
    _notifyState();
  }

  void _ensureConnectivityWatch() {
    if (_connectivitySub != null || _disposed) return;
    try {
      _connectivitySub = Connectivity().onConnectivityChanged.listen(
        (results) {
          unawaited(onNetworkPathChanged(results));
        },
        onError: (e) {
          debugPrint('GatewayRealtime connectivity watch: $e');
        },
      );
      // Seed current path without forcing reconnect.
      unawaited(() async {
        try {
          final now = await Connectivity().checkConnectivity();
          _lastConnectivity ??= _normalizeConnectivity(now);
        } catch (_) {}
      }());
    } catch (e) {
      debugPrint('GatewayRealtime: connectivity_plus unavailable: $e');
    }
  }

  List<ConnectivityResult> _normalizeConnectivity(
    List<ConnectivityResult> raw,
  ) {
    final set = raw.toSet().toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return set;
  }

  bool _sameConnectivity(
    List<ConnectivityResult> a,
    List<ConnectivityResult> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _startForegroundPoll() {
    _pollTimer?.cancel();
    if (!_wantConnected || _disposed) return;
    _pollTimer = Timer.periodic(foregroundPollInterval, (_) {
      if (!_wantConnected || _disposed || !_foregrounded) return;
      if (!_client.isOpen) return;
      unawaited(refreshCaches(reason: 'poll'));
    });
  }

  void _startLivenessProbe() {
    _livenessTimer?.cancel();
    if (!_wantConnected || _disposed) return;
    _livenessTimer = Timer.periodic(livenessInterval, (_) {
      if (!_wantConnected || _disposed || !_foregrounded) return;
      if (!_client.isOpen) return;
      unawaited(() async {
        final ok = await probeLiveness(disconnectOnFail: false);
        if (!ok &&
            _livenessFailCount >= livenessFailThreshold &&
            _wantConnected &&
            !_gaveUp) {
          debugPrint(
            'GatewayRealtime: ${livenessFailThreshold}x liveness fail — reconnect',
          );
          _scheduleReconnect();
        }
      }());
    });
  }

  /// Pull sessions (+ optional messages) and notify UI listeners.
  Future<void> refreshCaches({
    String? sessionId,
    String reason = 'event',
  }) async {
    if (_disposed || _refreshing) {
      if (_refreshing) {
        _eventRefreshDebounce?.cancel();
        _eventRefreshDebounce = Timer(const Duration(milliseconds: 400), () {
          unawaited(refreshCaches(sessionId: sessionId, reason: reason));
        });
      }
      return;
    }
    _refreshing = true;
    try {
      final keep = _keepIds?.call() ?? const <String>[];
      await _sessionSync.syncSessions(keepIds: keep);
      if (sessionId != null && sessionId.isNotEmpty) {
        try {
          await _sessionSync.syncMessages(sessionId);
        } catch (e) {
          debugPrint('GatewayRealtime message sync $sessionId: $e');
        }
      }
    } catch (e) {
      debugPrint('GatewayRealtime cache refresh failed ($reason): $e');
    } finally {
      _refreshing = false;
    }
    if (!_sessionTouchController.isClosed) {
      _sessionTouchController.add(
        SessionTouch(sessionId: sessionId, reason: reason),
      );
    }
  }

  void _scheduleEventRefresh({String? sessionId}) {
    _eventRefreshDebounce?.cancel();
    _eventRefreshDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(refreshCaches(sessionId: sessionId, reason: 'event'));
    });
  }

  Future<bool> _connectOnce() async {
    if (_disposed || !_wantConnected) return false;
    if (_gaveUp) return false;
    if (_client.isOpen) {
      lastError = null;
      return true;
    }
    final existing = _connectLock;
    if (existing != null) return existing;

    final run = _connectOnceBody();
    _connectLock = run;
    var connected = false;
    try {
      connected = await run;
      return connected;
    } finally {
      if (identical(_connectLock, run)) {
        _connectLock = null;
      }
      // Failure handlers run inside `_connectOnceBody`, while this lock is
      // intentionally held. Scheduling there was therefore discarded by
      // `_scheduleReconnect`'s single-flight guard. Schedule only after the
      // owner releases the lock so a failed ticket request or handshake
      // always advances the retry loop.
      if (!connected) _scheduleReconnect();
    }
  }

  Future<bool> _connectOnceBody() async {
    if (_disposed || !_wantConnected || _gaveUp) return false;
    if (_client.isOpen) {
      lastError = null;
      return true;
    }
    String wsUrl;
    try {
      // Mint ticket immediately before open — tickets are single-use + 30s TTL.
      wsUrl = await _resolveWsUrl().timeout(
        wsUrlResolutionTimeout,
        onTimeout: () => throw TimeoutException(
          'WebSocket ticket preparation timed out after '
          '${wsUrlResolutionTimeout.inSeconds}s',
          wsUrlResolutionTimeout,
        ),
      );
    } catch (e) {
      lastError = 'Could not mint WS ticket: $e';
      debugPrint('GatewayRealtime: $lastError');
      _notifyState();
      return false;
    }
    try {
      debugPrint(
        'GatewayRealtime connecting ${GatewayWsClient.redactUrl(wsUrl)} '
        '(attempt ${_reconnectAttempt + 1})',
      );
      _notifyState();
      await _client.connect(wsUrl);
      if (!_client.isOpen) {
        lastError = 'WebSocket finished handshake but is not open';
        _notifyState();
        return false;
      }
      await _events?.cancel();
      await _states?.cancel();
      _events = _client.events.listen(
        _onEvent,
        onError: (e) {
          debugPrint('GatewayRealtime event error: $e');
        },
      );
      _states = _client.states.listen((s) {
        _notifyState();
        if (s == GatewayWsState.open) {
          markHealthy();
        }
        if (s == GatewayWsState.closed || s == GatewayWsState.error) {
          _clearWorkingSessions();
          // Intentional close for force remint must NOT schedule reconnect
          // (that race left Settings stuck on "reconnecting").
          if (_wantConnected && !_gaveUp && !_suppressReconnect) {
            lastError = 'WebSocket $s';
            _scheduleReconnect();
          }
        }
      });

      // Warm list (Desktop does the same); failure ≠ dead socket.
      try {
        await _client.requestWithTimeout('session.list', {
          'limit': 100,
        }, const Duration(seconds: 20));
        markHealthy();
      } catch (e) {
        debugPrint('session.list over WS failed: $e');
      }

      _onConnectSuccess();
      debugPrint('GatewayRealtime live on ${GatewayWsClient.redactUrl(wsUrl)}');
      _notifyState();
      _startForegroundPoll();
      _startLivenessProbe();
      unawaited(refreshCaches(reason: 'connect'));
      unawaited(_sessionSync.flushPendingOverWs());
      return _client.isOpen;
    } catch (e) {
      lastError = 'WebSocket connect failed: $e';
      debugPrint('GatewayRealtime: $lastError');
      _notifyState();
      return false;
    }
  }

  void _onConnectSuccess() {
    lastError = null;
    _reconnectAttempt = 0;
    _gaveUp = false;
    _livenessFailCount = 0;
    _suppressReconnect = false;
    markHealthy();
    _reconnectWindowStarted = null;
    _nextRetryIn = null;
    _nextRetryAt = null;
    _reconnect?.cancel();
    _reconnect = null;
    _retryUiTicker?.cancel();
    _retryUiTicker = null;
  }

  void _notifyState() {
    if (!_stateTick.isClosed) _stateTick.add(null);
  }

  void _startRetryUiTicker() {
    _retryUiTicker?.cancel();
    // Refresh Settings countdown every second while waiting.
    _retryUiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_reconnect == null || _nextRetryAt == null) {
        _retryUiTicker?.cancel();
        _retryUiTicker = null;
        return;
      }
      _notifyState();
    });
  }

  /// Desktop freshGatewayWsUrl: ticket for session auth, token otherwise.
  Future<String> _resolveWsUrl() async {
    if (profile.usesSessionCookies) {
      final jar = await GatewayAuthClient.persistentJar(profile.id);
      final auth = GatewayAuthClient(baseUrl: profile.baseUrl, cookieJar: jar);
      try {
        final ticket = await auth.mintWsTicket();
        return GatewayWsClient.buildWsUrl(profile.baseUrl, ticket: ticket);
      } on GatewayAuthException catch (e) {
        lastError = e.message;
        if (e.needsReauth) {
          _signalReauth(e.message);
        }
        rethrow;
      }
    }
    if (profile.hasLegacyToken) {
      return GatewayWsClient.buildWsUrl(profile.baseUrl, token: profile.apiKey);
    }
    return GatewayWsClient.buildWsUrl(profile.baseUrl);
  }

  void _signalReauth(String message) {
    debugPrint('GatewayRealtime: needs reauth — $message');
    _wantConnected = false;
    _gaveUp = true;
    _reconnect?.cancel();
    _reconnect = null;
    try {
      _onNeedsReauth?.call(message);
    } catch (e) {
      debugPrint('GatewayRealtime: onNeedsReauth failed: $e');
    }
    _notifyState();
  }

  /// Exponential backoff + jitter (Desktop: 1s·2^n, cap 15s).
  Duration _nextBackoffDelay() {
    final exp =
        reconnectBase.inMilliseconds * (1 << math.min(_reconnectAttempt, 4));
    final capped = math.min(exp, reconnectCap.inMilliseconds);
    // Jitter 50–100% of delay — spreads thundering herd after gateway restart.
    final jittered = (capped * (0.5 + _rng.nextDouble() * 0.5)).round();
    return Duration(milliseconds: math.max(250, jittered));
  }

  void _scheduleReconnect() {
    if (!_wantConnected || _disposed || _gaveUp || _suppressReconnect) return;
    if (_client.isOpen) return;
    if (_reconnect != null) return; // already scheduled
    if (_connectLock != null) return;

    _reconnectWindowStarted ??= DateTime.now();
    final elapsed = DateTime.now().difference(_reconnectWindowStarted!);

    if (_reconnectAttempt >= maxReconnectAttempts ||
        elapsed >= maxReconnectWindow) {
      _gaveUp = true;
      lastError = lastError == null || lastError!.isEmpty
          ? 'Gave up after $_reconnectAttempt attempts. Tap Reconnect.'
          : '$lastError (gave up — tap Reconnect)';
      debugPrint('GatewayRealtime: give up reconnecting — $lastError');
      _notifyState();
      return;
    }

    final delay = _nextBackoffDelay();
    _nextRetryIn = delay;
    _nextRetryAt = DateTime.now().add(delay);
    final attemptForLog = _reconnectAttempt + 1;
    debugPrint(
      'GatewayRealtime: reconnect in ${delay.inMilliseconds}ms '
      '(attempt $attemptForLog)',
    );
    _notifyState();

    _startRetryUiTicker();
    _reconnect = Timer(delay, () {
      _reconnect = null;
      _nextRetryIn = null;
      _nextRetryAt = null;
      _retryUiTicker?.cancel();
      _retryUiTicker = null;
      if (!_wantConnected || _disposed || _gaveUp || _client.isOpen) {
        _notifyState();
        return;
      }
      _reconnectAttempt += 1;
      unawaited(_connectOnce());
    });
  }

  void _onEvent(GatewayWsEvent event) {
    final type = event.type;
    _trackWorkingSession(event);
    // Traffic proves liveness; avoid state-tick spam on high-frequency deltas.
    final isDelta =
        type == 'message.delta' ||
        type == 'thinking.delta' ||
        type == 'reasoning.delta';
    markHealthy(notifyIfErrorCleared: !isDelta);
    if (isDelta) return;
    debugPrint('GatewayRealtime event: $type session=${event.sessionId}');

    if (_eventAffectsSessions(type)) {
      _scheduleEventRefresh(sessionId: event.sessionId);
    }

    if (type == 'message.complete' || type == 'background.complete') {
      unawaited(_maybeNotifyCompletion(event));
    }
  }

  void _trackWorkingSession(GatewayWsEvent event) {
    final sessionId = event.sessionId?.trim();
    if (sessionId == null || sessionId.isEmpty) return;
    final starts =
        event.type == 'message.start' ||
        event.type == 'tool.start' ||
        event.type == 'thinking.start' ||
        event.type == 'reasoning.start' ||
        event.type == 'background.start';
    final stops =
        event.type == 'message.complete' ||
        event.type == 'background.complete' ||
        event.type == 'error' ||
        event.type == 'session.reclaimed' ||
        event.type == 'session.closed';
    final changed = starts
        ? _workingSessionIds.add(sessionId)
        : stops
        ? _workingSessionIds.remove(sessionId)
        : false;
    if (changed && !_workingSessionController.isClosed) {
      _workingSessionController.add(workingSessionIds);
    }
  }

  void _clearWorkingSessions() {
    if (_workingSessionIds.isEmpty) return;
    _workingSessionIds.clear();
    if (!_workingSessionController.isClosed) {
      _workingSessionController.add(const <String>{});
    }
  }

  bool _eventAffectsSessions(String type) {
    if (type.isEmpty) return false;
    return type == 'message.complete' ||
        type == 'message.start' ||
        type == 'background.complete' ||
        type == 'session.info' ||
        type == 'status.update' ||
        type == 'tool.complete' ||
        type == 'tool.start' ||
        type == 'error' ||
        type == 'gateway.ready' ||
        type.startsWith('session.');
  }

  Future<void> _maybeNotifyCompletion(GatewayWsEvent event) async {
    final sid = event.sessionId;
    if (sid == null || sid.isEmpty) return;
    final type = event.type;

    final watches = await WatchStore().forGateway(profile.id);
    SessionWatch? matched;
    for (final w in watches) {
      if (w.matchesSession(sid)) {
        matched = w;
        break;
      }
      // Live id on wire vs stored id in watch — expand via session map.
      final family = _sessionSync.sessionIdFamily(sid);
      if (family.any(w.matchesSession)) {
        matched = w;
        break;
      }
    }

    final inflight = _sessionSync.isInflightSession(sid);
    final bg = AppLifecycle.isBackground;

    // Notify when: explicitly watched, background job done, our inflight turn,
    // or app is backgrounded (user left while waiting).
    final shouldNotify =
        matched != null || type == 'background.complete' || inflight || bg;
    if (!shouldNotify) return;

    String body = 'Agent finished';
    try {
      // Prefer stored id for local cache load.
      final loadId = matched?.sessionId ?? sid;
      var msgs = await _sessionSync.loadMessagesLocal(loadId);
      if (msgs.isEmpty && loadId != sid) {
        msgs = await _sessionSync.loadMessagesLocal(sid);
      }
      final lastAssistant = msgs.reversed
          .where((m) => m.isAssistant)
          .firstOrNull;
      final preview = (lastAssistant?.content ?? '').trim();
      if (preview.isNotEmpty) {
        body = preview.length > 160 ? '${preview.substring(0, 160)}…' : preview;
      }
    } catch (_) {}

    final title = type == 'background.complete'
        ? 'Hermes job / background done'
        : ((matched?.title ?? '').trim().isNotEmpty
              ? matched!.title!.trim()
              : 'Hermes ready');
    final notifyId = matched?.sessionId ?? sid;
    await ResultNotifier.instance.showSessionResult(
      sessionId: notifyId,
      title: title,
      body: body,
    );
    // Clear watch family so we do not double-notify from session_sync finalize.
    final clearIds = {
      sid,
      notifyId,
      ..._sessionSync.sessionIdFamily(sid),
      if (matched != null) ...matched.allIds,
    };
    await WatchStore().unwatchAllMatching(profile.id, clearIds);
  }

  Future<List<HermesSession>> listSessionsRpc() async {
    if (!_client.isOpen) return _sessionSync.loadSessionsLocal();
    try {
      final result = await _client.request('session.list', {'limit': 100});
      final raw = result['sessions'];
      if (raw is! List) return _sessionSync.loadSessionsLocal();
      return [
        for (final item in raw)
          if (item is Map)
            HermesSession(
              id: '${item['id'] ?? ''}',
              title: item['title'] as String?,
              preview: item['preview'] as String?,
              startedAt: item['started_at']?.toString(),
              messageCount: item['message_count'] is int
                  ? item['message_count'] as int
                  : int.tryParse('${item['message_count']}'),
              source: item['source'] as String?,
            ),
      ].where((s) => s.id.isNotEmpty).toList();
    } catch (_) {
      return _sessionSync.loadSessionsLocal();
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _wantConnected = false;
    _reconnect?.cancel();
    _retryUiTicker?.cancel();
    _pathChangeDebounce?.cancel();
    _eventRefreshDebounce?.cancel();
    _pollTimer?.cancel();
    _livenessTimer?.cancel();
    await _connectivitySub?.cancel();
    await stop();
    await _sessionTouchController.close();
    await _stateTick.close();
    await _workingSessionController.close();
    await _client.dispose();
  }
}

/// Machine + human WebSocket status for Settings / chrome.
enum GatewayWsUiPhase {
  live,
  connecting,
  reconnecting,
  offline,
  stopped,
  gaveUp,
}

class GatewayWsUiStatus {
  const GatewayWsUiStatus({
    required this.phase,
    required this.label,
    this.detail,
    this.attempt = 0,
    this.nextDelay,
  });

  final GatewayWsUiPhase phase;
  final String label;
  final String? detail;
  final int attempt;
  final Duration? nextDelay;

  bool get isLive => phase == GatewayWsUiPhase.live;
  bool get isRetrying =>
      phase == GatewayWsUiPhase.connecting ||
      phase == GatewayWsUiPhase.reconnecting;
}
