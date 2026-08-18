import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// JSON-RPC over WebSocket — same wire protocol as Desktop (`apps/shared`
/// JsonRpcGatewayClient) and the dashboard Chat tab (`/api/ws`).
///
/// Desktop does **not** poll sessions every 15 minutes. It keeps this socket
/// open and receives push events (`message.delta`, `message.complete`,
/// `session.info`, `background.complete`, …).
class GatewayWsClient {
  GatewayWsClient();

  static const _closeTimeout = Duration(seconds: 2);

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  final _pending = <Object, Completer<Map<String, dynamic>>>{};
  final _eventController = StreamController<GatewayWsEvent>.broadcast();
  final _stateController = StreamController<GatewayWsState>.broadcast();
  var _nextId = 1;
  GatewayWsState _state = GatewayWsState.idle;
  String? _url;

  /// Single-flight connect — concurrent callers join the same attempt.
  Completer<void>? _connectInflight;

  Stream<GatewayWsEvent> get events => _eventController.stream;
  Stream<GatewayWsState> get states => _stateController.stream;
  GatewayWsState get state => _state;
  bool get isOpen => _state == GatewayWsState.open;
  String? get url => _url;

  /// Build `ws(s)://host[:port]/api/ws?…` from an HTTP base URL.
  ///
  /// Desktop gated mode uses `?ticket=` (single-use, from POST /api/auth/ws-ticket).
  /// Loopback/token mode uses `?token=`.
  static String buildWsUrl(String httpBase, {String? token, String? ticket}) {
    final uri = Uri.parse(httpBase.trim());
    final scheme = (uri.scheme == 'https' || uri.scheme == 'wss')
        ? 'wss'
        : 'ws';
    final path = uri.path.endsWith('/')
        ? '${uri.path}api/ws'
        : (uri.path.isEmpty ? '/api/ws' : '${uri.path}/api/ws');
    // Collapse accidental //api
    final cleanPath = path.replaceAll(RegExp(r'/+'), '/');
    final q = <String, String>{};
    if (ticket != null && ticket.isNotEmpty) {
      q['ticket'] = ticket;
    } else if (token != null && token.isNotEmpty) {
      q['token'] = token;
    }
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: cleanPath,
      queryParameters: q.isEmpty ? null : q,
    ).toString();
  }

  /// Host-only form for logs (never print tickets/tokens).
  static String redactUrl(String wsUrl) {
    try {
      final u = Uri.parse(wsUrl);
      final q = Map<String, String>.from(u.queryParameters);
      if (q.containsKey('ticket')) q['ticket'] = '…';
      if (q.containsKey('token')) q['token'] = '…';
      return u.replace(queryParameters: q.isEmpty ? null : q).toString();
    } catch (_) {
      return '(bad-ws-url)';
    }
  }

  Future<void> connect(String wsUrl) async {
    // Already open — nothing to do.
    if (_state == GatewayWsState.open && _channel != null) {
      return;
    }

    // Join in-flight attempt (do NOT early-return while connecting — that left
    // callers thinking they connected while the socket was still mid-handshake).
    final inflight = _connectInflight;
    if (inflight != null) {
      return inflight.future;
    }

    final attempt = Completer<void>();
    // The initiating caller awaits this method's async body, while concurrent
    // callers await `attempt.future`. Give the shared future an error handler
    // immediately so completing it with the same handshake error does not
    // become an uncaught zone error when there are no concurrent callers.
    unawaited(
      attempt.future.then<void>((_) {}, onError: (Object _, StackTrace _) {}),
    );
    _connectInflight = attempt;
    _url = wsUrl;
    _setState(GatewayWsState.connecting);

    try {
      // Tear down any half-open channel first.
      await _hardCloseChannel();

      // IOWebSocketChannel: real dart:io errors on iOS (CF tunnel / Tailscale).
      // Avoid aggressive protocol pings — some reverse proxies / long tool
      // turns drop the socket if pong is delayed, thrashing "reconnecting".
      final channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        pingInterval: const Duration(seconds: 45),
        connectTimeout: const Duration(seconds: 12),
      );
      _channel = channel;

      await channel.ready.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
            'WebSocket handshake timed out (15s) to ${redactUrl(wsUrl)}',
          );
        },
      );

      _sub = channel.stream.listen(
        _onMessage,
        onError: (e) {
          debugPrint('GatewayWs error: $e');
          _failPending(e);
          _setState(GatewayWsState.error);
        },
        onDone: () {
          _failPending(StateError('WebSocket closed'));
          _setState(GatewayWsState.closed);
          _channel = null;
        },
        cancelOnError: false,
      );
      _setState(GatewayWsState.open);
      if (!attempt.isCompleted) attempt.complete();
    } catch (e) {
      await _hardCloseChannel();
      _setState(GatewayWsState.error);
      if (!attempt.isCompleted) attempt.completeError(e);
      rethrow;
    } finally {
      if (identical(_connectInflight, attempt)) {
        _connectInflight = null;
      }
    }
  }

  Future<void> _hardCloseChannel() async {
    final sub = _sub;
    _sub = null;
    final channel = _channel;
    _channel = null;
    try {
      await sub?.cancel().timeout(_closeTimeout);
    } catch (_) {}
    try {
      // A failed iOS/Tailscale handshake can leave the close future pending
      // just like its open future. Teardown is best-effort and must not hold
      // the reconnect single-flight lock indefinitely.
      await channel?.sink.close().timeout(_closeTimeout);
    } catch (_) {}
  }

  Future<void> disconnect() async {
    // Cancel any waiter on a mid-flight connect.
    final inflight = _connectInflight;
    _connectInflight = null;
    if (inflight != null && !inflight.isCompleted) {
      inflight.completeError(StateError('disconnected'));
    }
    await _hardCloseChannel();
    _failPending(StateError('disconnected'));
    _setState(GatewayWsState.closed);
  }

  /// JSON-RPC request → response `result` map (or throws).
  ///
  /// [timeout] defaults to 120s. Desktop uses up to 30m for `prompt.submit`
  /// ack in pathological cases; normal submit ACKs are immediate (`streaming`).
  Future<Map<String, dynamic>> request(
    String method, [
    Map<String, dynamic>? params,
  ]) async {
    return requestWithTimeout(method, params);
  }

  Future<Map<String, dynamic>> requestWithTimeout(
    String method, [
    Map<String, dynamic>? params,
    Duration? timeout,
  ]) async {
    final ch = _channel;
    if (ch == null || _state != GatewayWsState.open) {
      throw StateError('gateway not connected');
    }
    final id = 'm${_nextId++}';
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;
    ch.sink.add(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        'params': params ?? const <String, dynamic>{},
      }),
    );
    return completer.future.timeout(
      timeout ?? const Duration(seconds: 120),
      onTimeout: () {
        _pending.remove(id);
        throw TimeoutException('gateway request $method timed out');
      },
    );
  }

  void _onMessage(dynamic raw) {
    final text = raw is String ? raw : utf8.decode(raw as List<int>);
    // Newline-delimited JSON (same as Desktop / tui_gateway).
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final obj = jsonDecode(trimmed);
        if (obj is! Map) continue;
        final map = obj.cast<String, dynamic>();
        _handleFrame(map);
      } catch (e) {
        debugPrint('GatewayWs bad frame: $e');
      }
    }
  }

  void _handleFrame(Map<String, dynamic> map) {
    // Response to a request
    if (map.containsKey('id') &&
        map['id'] != null &&
        !map.containsKey('method')) {
      final id = map['id'];
      final pending = _pending.remove(id);
      if (pending == null) return;
      if (map['error'] != null) {
        final err = map['error'];
        if (err is Map) {
          final rawCode = err['code'];
          final code = rawCode is int ? rawCode : int.tryParse('$rawCode');
          pending.completeError(
            GatewayRpcException('${err['message'] ?? err}', code: code),
          );
        } else {
          pending.completeError(GatewayRpcException('$err'));
        }
        return;
      }
      final result = map['result'];
      if (result is Map) {
        pending.complete(result.cast<String, dynamic>());
      } else {
        pending.complete({'value': result});
      }
      return;
    }

    // Notification / event: { method: "...", params: { type, session_id, ... } }
    // or params is the event itself.
    final params = map['params'];
    if (params is Map) {
      final p = params.cast<String, dynamic>();
      final type = '${p['type'] ?? map['method'] ?? ''}';
      if (type.isEmpty) return;
      _eventController.add(
        GatewayWsEvent(
          type: type,
          sessionId: p['session_id']?.toString() ?? p['sessionId']?.toString(),
          payload: p,
        ),
      );
      return;
    }

    // Bare event object
    final type = '${map['type'] ?? ''}';
    if (type.isNotEmpty) {
      _eventController.add(
        GatewayWsEvent(
          type: type,
          sessionId: map['session_id']?.toString(),
          payload: map,
        ),
      );
    }
  }

  void _failPending(Object error) {
    final pending = Map<Object, Completer<Map<String, dynamic>>>.from(_pending);
    _pending.clear();
    for (final c in pending.values) {
      if (!c.isCompleted) c.completeError(error);
    }
  }

  void _setState(GatewayWsState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }

  Future<void> dispose() async {
    await disconnect();
    await _eventController.close();
    await _stateController.close();
  }
}

enum GatewayWsState { idle, connecting, open, closed, error }

/// A JSON-RPC `error` response from a **live, connected** gateway — as
/// opposed to a transport failure (socket not open, timeout, connection
/// reset), which throws a plain [StateError] / [TimeoutException] instead.
///
/// [code] is the gateway's numeric error code from `tui_gateway/*.py`'s
/// `_err(rid, code, message)` (e.g. 4018 — permanent request rejection:
/// stale rewind/edit target, oversized attachment, unresolvable slash
/// command, …). Previously this code was discarded and every RPC error
/// surfaced as a bare `StateError(message)`, so callers could only guess
/// whether a rejection was permanent by pattern-matching message text.
class GatewayRpcException implements Exception {
  GatewayRpcException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

class GatewayWsEvent {
  const GatewayWsEvent({
    required this.type,
    this.sessionId,
    required this.payload,
  });

  final String type;
  final String? sessionId;
  final Map<String, dynamic> payload;
}
