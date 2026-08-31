import 'package:flutter/foundation.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

enum SyncQualityState { synced, syncing, delayed, offline }

@immutable
class ListeningSessionEntity {
  final String id;
  final String roomId;
  final SongEntity? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final SyncQualityState syncQuality;
  final DateTime startedAt;

  const ListeningSessionEntity({
    required this.id,
    required this.roomId,
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.syncQuality = SyncQualityState.synced,
    required this.startedAt,
  });

  ListeningSessionEntity copyWith({
    String? id,
    String? roomId,
    SongEntity? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    SyncQualityState? syncQuality,
    DateTime? startedAt,
  }) {
    return ListeningSessionEntity(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      syncQuality: syncQuality ?? this.syncQuality,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
