import 'package:flutter/foundation.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

@immutable
class QueueEntity {
  final SongEntity? currentSong;
  final List<SongEntity> upcomingSongs;
  final List<SongEntity> previousSongs;

  const QueueEntity({
    this.currentSong,
    this.upcomingSongs = const [],
    this.previousSongs = const [],
  });

  int get totalLength =>
      (currentSong != null ? 1 : 0) +
      upcomingSongs.length +
      previousSongs.length;

  Duration get totalDuration {
    Duration duration = currentSong?.duration ?? Duration.zero;
    for (final song in upcomingSongs) {
      duration += song.duration;
    }
    for (final song in previousSongs) {
      duration += song.duration;
    }
    return duration;
  }

  QueueEntity copyWith({
    SongEntity? currentSong,
    List<SongEntity>? upcomingSongs,
    List<SongEntity>? previousSongs,
  }) {
    return QueueEntity(
      currentSong: currentSong ?? this.currentSong,
      upcomingSongs: upcomingSongs ?? this.upcomingSongs,
      previousSongs: previousSongs ?? this.previousSongs,
    );
  }
}
