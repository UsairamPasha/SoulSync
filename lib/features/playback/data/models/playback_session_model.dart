import 'package:soulsync/features/playback/domain/entities/playback_session_entity.dart';

class PlaybackSessionModel extends PlaybackSessionEntity {
  const PlaybackSessionModel({
    required super.id,
    required super.roomId,
    required super.hostUserId,
    super.hostName,
    super.currentSongId,
    super.playbackState,
    super.positionMs,
    super.durationMs,
    super.startedAt,
    super.updatedAt,
    super.isActive,
  });

  factory PlaybackSessionModel.fromEntity(PlaybackSessionEntity entity) {
    return PlaybackSessionModel(
      id: entity.id,
      roomId: entity.roomId,
      hostUserId: entity.hostUserId,
      hostName: entity.hostName,
      currentSongId: entity.currentSongId,
      playbackState: entity.playbackState,
      positionMs: entity.positionMs,
      durationMs: entity.durationMs,
      startedAt: entity.startedAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }

  factory PlaybackSessionModel.fromJson(Map<String, dynamic> json) {
    return PlaybackSessionModel(
      id: json['id'] as String? ?? json['sessionId'] as String? ?? 'session_default',
      roomId: json['room_id'] as String? ?? json['roomId'] as String? ?? 'soul_sync_room_default',
      hostUserId: json['host_id'] as String? ?? json['hostId'] as String? ?? 'user_host_1',
      hostName: json['host_name'] as String? ?? json['hostName'] as String? ?? 'Host',
      currentSongId: json['current_song_id'] as String? ?? json['currentSongId'] as String? ?? 'song_1',
      playbackState: PlaybackLifecycleState.fromString(
        json['playback_state'] as String? ?? json['playbackState'] as String?,
      ),
      positionMs: (json['playback_position_ms'] as num? ?? json['positionMs'] as num? ?? 0).toInt(),
      durationMs: (json['duration_ms'] as num? ?? json['durationMs'] as num? ?? 0).toInt(),
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'host_id': hostUserId,
      'host_name': hostName,
      'current_song_id': currentSongId,
      'playback_state': playbackState.toServerString(),
      'playback_position_ms': positionMs,
      'duration_ms': durationMs,
      'started_at': startedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}
