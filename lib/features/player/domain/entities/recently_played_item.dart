import 'package:flutter/foundation.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

@immutable
class RecentlyPlayedItem {
  final SongEntity song;
  final DateTime playedAt;
  final int playCount;

  const RecentlyPlayedItem({
    required this.song,
    required this.playedAt,
    this.playCount = 1,
  });

  RecentlyPlayedItem copyWith({
    SongEntity? song,
    DateTime? playedAt,
    int? playCount,
  }) {
    return RecentlyPlayedItem(
      song: song ?? this.song,
      playedAt: playedAt ?? this.playedAt,
      playCount: playCount ?? this.playCount,
    );
  }
}
