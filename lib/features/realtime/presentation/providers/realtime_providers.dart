import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/config/app_config.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/profile/presentation/providers/profile_providers.dart';
import 'package:soulsync/features/realtime/services/web_socket_service.dart';

import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenManager = ref.watch(authTokenManagerProvider);
  final authState = ref.watch(authNotifierProvider);
  final service = WebSocketService(config: config, tokenManager: tokenManager);
  if (authState.status == AuthStatus.authenticated) {
    service.connect();
  }
  ref.onDispose(() => service.dispose());
  return service;
});

enum AppConnectionStatus {
  disconnected,
  connecting,
  connected,
  partnerOffline,
  reconnecting,
  listeningTogether,
}

final connectionStatusProvider = Provider<AppConnectionStatus>((ref) {
  final relState = ref.watch(relationshipNotifierProvider);
  if (relState.relationship == null) {
    return AppConnectionStatus.disconnected;
  }

  final ws = ref.watch(webSocketServiceProvider);
  final presence = ref.watch(partnerPresenceNotifierProvider);
  final sessionSync = ref.watch(sessionSyncNotifierProvider);

  if (ws.status == RealtimeConnectionStatus.connecting) {
    return AppConnectionStatus.connecting;
  }
  if (ws.status == RealtimeConnectionStatus.reconnecting) {
    return AppConnectionStatus.reconnecting;
  }
  if (ws.status == RealtimeConnectionStatus.disconnected ||
      ws.status == RealtimeConnectionStatus.authFailed) {
    return AppConnectionStatus.disconnected;
  }

  if (sessionSync.isPlaying && presence.isOnline) {
    return AppConnectionStatus.listeningTogether;
  }
  if (!presence.isOnline) {
    return AppConnectionStatus.partnerOffline;
  }
  return AppConnectionStatus.connected;
});

// Presence State
class PartnerPresenceState {
  final bool isOnline;
  final DateTime? lastSeen;
  final int latencyMs;
  final ConnectionQuality quality;

  const PartnerPresenceState({
    this.isOnline = false,
    this.lastSeen,
    this.latencyMs = 0,
    this.quality = ConnectionQuality.offline,
  });

  PartnerPresenceState copyWith({
    bool? isOnline,
    DateTime? lastSeen,
    int? latencyMs,
    ConnectionQuality? quality,
  }) {
    return PartnerPresenceState(
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      latencyMs: latencyMs ?? this.latencyMs,
      quality: quality ?? this.quality,
    );
  }
}

class PartnerPresenceNotifier extends StateNotifier<PartnerPresenceState> {
  final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _msgSub;
  StreamSubscription<int>? _latencySub;

  PartnerPresenceNotifier(this._wsService)
      : super(const PartnerPresenceState()) {
    _initListeners();
  }

  void _initListeners() {
    _msgSub = _wsService.messageStream.listen((data) {
      if (data['type'] == 'presence_update') {
        final isOnline = data['isOnline'] as bool? ?? false;
        final lastSeenStr = data['lastSeen'] as String?;
        final lastSeen =
            lastSeenStr != null ? DateTime.tryParse(lastSeenStr) : null;

        state = state.copyWith(
          isOnline: isOnline,
          lastSeen: lastSeen,
        );
      }
    });

    _latencySub = _wsService.latencyStream.listen((latency) {
      state = state.copyWith(
        latencyMs: latency,
        quality: _wsService.quality,
      );
    });
  }

  void reset() {
    state = const PartnerPresenceState(
      isOnline: false,
      lastSeen: null,
      latencyMs: 0,
      quality: ConnectionQuality.offline,
    );
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _latencySub?.cancel();
    super.dispose();
  }
}

final partnerPresenceNotifierProvider =
    StateNotifierProvider<PartnerPresenceNotifier, PartnerPresenceState>((ref) {
  final ws = ref.watch(webSocketServiceProvider);
  return PartnerPresenceNotifier(ws);
});

// Session Sync State
class SessionSyncState {
  final String? currentSongId;
  final Duration position;
  final bool isPlaying;
  final int queueVersion;

  const SessionSyncState({
    this.currentSongId,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.queueVersion = 1,
  });

  SessionSyncState copyWith({
    String? currentSongId,
    Duration? position,
    bool? isPlaying,
    int? queueVersion,
  }) {
    return SessionSyncState(
      currentSongId: currentSongId ?? this.currentSongId,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      queueVersion: queueVersion ?? this.queueVersion,
    );
  }
}

class SessionSyncNotifier extends StateNotifier<SessionSyncState> {
  final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _msgSub;

  SessionSyncNotifier(this._wsService) : super(const SessionSyncState()) {
    _msgSub = _wsService.messageStream.listen((data) {
      if (data['type'] == 'session_state_update' && data['state'] != null) {
        final st = data['state'] as Map<String, dynamic>;
        state = state.copyWith(
          currentSongId: st['songId'] as String?,
          position: Duration(milliseconds: st['positionMs'] as int? ?? 0),
          isPlaying: st['isPlaying'] as bool? ?? false,
          queueVersion: st['queueVersion'] as int? ?? 1,
        );
      }
    });
  }

  void syncState({
    required String songId,
    required Duration position,
    required bool isPlaying,
  }) {
    state = state.copyWith(
      currentSongId: songId,
      position: position,
      isPlaying: isPlaying,
    );
    _wsService.send({
      'type': 'session_sync',
      'songId': songId,
      'positionMs': position.inMilliseconds,
      'isPlaying': isPlaying,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }
}

final sessionSyncNotifierProvider =
    StateNotifierProvider<SessionSyncNotifier, SessionSyncState>((ref) {
  final ws = ref.watch(webSocketServiceProvider);
  return SessionSyncNotifier(ws);
});

