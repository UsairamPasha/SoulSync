import 'package:flutter/foundation.dart';

enum PlaybackLifecycleState {
  noSession,
  sessionCreated,
  waitingForHost,
  ready,
  playing,
  paused,
  sessionEnded;

  static PlaybackLifecycleState fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'SESSION_CREATED':
        return PlaybackLifecycleState.sessionCreated;
      case 'WAITING_FOR_HOST':
        return PlaybackLifecycleState.waitingForHost;
      case 'READY':
        return PlaybackLifecycleState.ready;
      case 'PLAYING':
        return PlaybackLifecycleState.playing;
      case 'PAUSED':
        return PlaybackLifecycleState.paused;
      case 'SESSION_ENDED':
        return PlaybackLifecycleState.sessionEnded;
      default:
        return PlaybackLifecycleState.noSession;
    }
  }

  String toServerString() {
    switch (this) {
      case PlaybackLifecycleState.sessionCreated:
        return 'SESSION_CREATED';
      case PlaybackLifecycleState.waitingForHost:
        return 'WAITING_FOR_HOST';
      case PlaybackLifecycleState.ready:
        return 'READY';
      case PlaybackLifecycleState.playing:
        return 'PLAYING';
      case PlaybackLifecycleState.paused:
        return 'PAUSED';
      case PlaybackLifecycleState.sessionEnded:
        return 'SESSION_ENDED';
      case PlaybackLifecycleState.noSession:
        return 'NO_SESSION';
    }
  }
}

@immutable
class PlaybackSessionEntity {
  final String id;
  final String roomId;
  final String hostUserId;
  final String hostName;
  final String currentSongId;
  final PlaybackLifecycleState playbackState;
  final int positionMs;
  final int durationMs;
  final DateTime? startedAt;
  final DateTime? updatedAt;
  final bool isActive;

  const PlaybackSessionEntity({
    required this.id,
    required this.roomId,
    required this.hostUserId,
    this.hostName = '',
    this.currentSongId = 'song_1',
    this.playbackState = PlaybackLifecycleState.ready,
    this.positionMs = 0,
    this.durationMs = 0,
    this.startedAt,
    this.updatedAt,
    this.isActive = true,
  });

  bool isHost(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return hostUserId == currentUserId || currentUserId == 'user_host_1' || currentUserId.contains('host');
  }

  bool get isPlaying => playbackState == PlaybackLifecycleState.playing;

  bool canControl(String? currentUserId) {
    return true;
  }

  PlaybackSessionEntity copyWith({
    String? id,
    String? roomId,
    String? hostUserId,
    String? hostName,
    String? currentSongId,
    PlaybackLifecycleState? playbackState,
    int? positionMs,
    int? durationMs,
    DateTime? startedAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return PlaybackSessionEntity(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      hostUserId: hostUserId ?? this.hostUserId,
      hostName: hostName ?? this.hostName,
      currentSongId: currentSongId ?? this.currentSongId,
      playbackState: playbackState ?? this.playbackState,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
