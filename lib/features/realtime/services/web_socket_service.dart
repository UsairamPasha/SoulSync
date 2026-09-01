import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:soulsync/core/config/app_config.dart';
import 'package:soulsync/core/logger/app_logger.dart';
import 'package:soulsync/core/security/auth_token_manager.dart';

enum RealtimeConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  authFailed,
}

enum ConnectionQuality {
  excellent,
  good,
  fair,
  poor,
  offline,
}

class WebSocketService {
  final AppConfig _config;
  final AuthTokenManager _tokenManager;

  WebSocketChannel? _channel;
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;
  int _latencyMs = 0;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final _statusController =
      StreamController<RealtimeConnectionStatus>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _latencyController = StreamController<int>.broadcast();

  WebSocketService({
    required AppConfig config,
    required AuthTokenManager tokenManager,
  })  : _config = config,
        _tokenManager = tokenManager;

  RealtimeConnectionStatus get status => _status;
  int get latencyMs => _latencyMs;
  Stream<RealtimeConnectionStatus> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<int> get latencyStream => _latencyController.stream;

  ConnectionQuality get quality {
    if (_status != RealtimeConnectionStatus.connected) {
      return ConnectionQuality.offline;
    }
    if (_latencyMs < 100) return ConnectionQuality.excellent;
    if (_latencyMs < 250) return ConnectionQuality.good;
    if (_latencyMs < 500) return ConnectionQuality.fair;
    return ConnectionQuality.poor;
  }

  Future<void> reconnectIfNeeded() async {
    if (_status == RealtimeConnectionStatus.disconnected ||
        _status == RealtimeConnectionStatus.reconnecting ||
        _status == RealtimeConnectionStatus.authFailed) {
      AppLogger.info('[Realtime] App resumed/recovered - forcing reconnect procedure');
      _reconnectAttempts = 0;
      await connect();
    }
  }

  Future<void> connect() async {
    if (_status == RealtimeConnectionStatus.connected ||
        _status == RealtimeConnectionStatus.connecting) {
      return;
    }

    _updateStatus(RealtimeConnectionStatus.connecting);
    final token = await _tokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      AppLogger.warning('[Realtime] Connection failed: No JWT token found.');
      _updateStatus(RealtimeConnectionStatus.authFailed);
      return;
    }

    try {
      final wsHost = _config.baseUrl
          .replaceAll('http://', 'ws://')
          .replaceAll('https://', 'wss://');
      final wsUrl = '$wsHost/ws/presence/?token=$token';

      AppLogger.debug('[Realtime] Connecting to WebSocket: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _updateStatus(RealtimeConnectionStatus.connected);
      _reconnectAttempts = 0;
      AppLogger.info('[Realtime] WebSocket Connected');

      _startHeartbeat();

      _channel?.stream.listen(
        (data) {
          try {
            if (data is String) {
              final map = jsonDecode(data) as Map<String, dynamic>;
              _messageController.add(map);

              if (map['type'] == 'pong') {
                _calculateLatency();
              }
            }
          } catch (e) {
            AppLogger.error('[Realtime] Message parse error', e);
          }
        },
        onDone: () {
          AppLogger.warning('[Realtime] WebSocket Closed');
          _handleDisconnect();
        },
        onError: (Object e) {
          AppLogger.error('[Realtime] WebSocket Error', e);
          _handleDisconnect();
        },
      );
    } catch (e) {
      AppLogger.error('[Realtime] Connection attempt failed', e);
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _channel?.sink.close();
    _channel = null;
    _stopHeartbeat();

    if (_status == RealtimeConnectionStatus.authFailed) return;

    if (_reconnectAttempts < 5) {
      _updateStatus(RealtimeConnectionStatus.reconnecting);
      _reconnectAttempts++;
      final delaySeconds =
          1 << _reconnectAttempts; // Exponential backoff: 2s, 4s, 8s, 16s...
      AppLogger.debug(
          '[Realtime] Reconnecting (attempt $_reconnectAttempts) in ${delaySeconds}s');

      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
        connect();
      });
    } else {
      _updateStatus(RealtimeConnectionStatus.disconnected);
    }
  }

  void send(Map<String, dynamic> data) {
    if (_status == RealtimeConnectionStatus.connected && _channel != null) {
      _channel?.sink.add(jsonEncode(data));
    }
  }

  DateTime? _pingSentTime;

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_status == RealtimeConnectionStatus.connected) {
        _pingSentTime = DateTime.now();
        send({
          'type': 'ping',
          'timestamp': _pingSentTime!.millisecondsSinceEpoch
        });
        AppLogger.debug('[Heartbeat] Sent ping');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _calculateLatency() {
    if (_pingSentTime != null) {
      _latencyMs = DateTime.now().difference(_pingSentTime!).inMilliseconds;
      _latencyController.add(_latencyMs);
      AppLogger.debug('[Heartbeat] Acknowledged (Latency: ${_latencyMs}ms)');
    }
  }

  void _updateStatus(RealtimeConnectionStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    await _channel?.sink.close();
    _channel = null;
    _updateStatus(RealtimeConnectionStatus.disconnected);
    AppLogger.info('[Realtime] Disconnected by user');
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
    _latencyController.close();
  }
}
