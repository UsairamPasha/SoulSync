import 'package:flutter/foundation.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

@immutable
class SharedQueueEntity {
  final String id;
  final String roomId;
  final int currentIndex;
  final List<SongEntity> songs;
  final String? ownerUserId;
  final DateTime? createdTimestamp;
  final DateTime? updatedTimestamp;

  const SharedQueueEntity({
    this.id = 'queue_default',
    this.roomId = 'soul_sync_room_default',
    this.currentIndex = 0,
    this.songs = const [],
    this.ownerUserId,
    this.createdTimestamp,
    this.updatedTimestamp,
  });

  int get length => songs.length;
  bool get isEmpty => songs.isEmpty;
  bool get isEnd => currentIndex >= songs.length - 1;

  int effectiveIndexForId(String? activeSongId) {
    if (activeSongId != null && activeSongId.isNotEmpty && songs.isNotEmpty) {
      final idx = songs.indexWhere((s) => s.id == activeSongId);
      if (idx != -1) return idx;
    }
    if (songs.isEmpty) return 0;
    return currentIndex.clamp(0, songs.length - 1);
  }

  SongEntity? getCurrentSong([String? activeSongId]) {
    if (songs.isEmpty) return null;
    final idx = effectiveIndexForId(activeSongId);
    if (idx >= 0 && idx < songs.length) {
      return songs[idx];
    }
    return null;
  }

  List<SongEntity> getUpNextSongs([String? activeSongId]) {
    if (songs.isEmpty) return const [];
    final idx = effectiveIndexForId(activeSongId);
    if (idx >= songs.length - 1) {
      return const [];
    }
    return songs.sublist(idx + 1);
  }

  List<SongEntity> getPreviousSongs([String? activeSongId]) {
    if (songs.isEmpty) return const [];
    final idx = effectiveIndexForId(activeSongId);
    if (idx <= 0) {
      return const [];
    }
    final end = idx.clamp(0, songs.length);
    return songs.sublist(0, end);
  }

  SongEntity? get currentSong => getCurrentSong();
  List<SongEntity> get upNextSongs => getUpNextSongs();
  List<SongEntity> get previousSongs => getPreviousSongs();

  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }

  SharedQueueEntity copyWith({
    String? id,
    String? roomId,
    int? currentIndex,
    List<SongEntity>? songs,
    String? ownerUserId,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) {
    return SharedQueueEntity(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      currentIndex: currentIndex ?? this.currentIndex,
      songs: songs ?? this.songs,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      updatedTimestamp: updatedTimestamp ?? this.updatedTimestamp,
    );
  }
}
