import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/queue/domain/entities/shared_queue_entity.dart';

class SharedQueueModel extends SharedQueueEntity {
  const SharedQueueModel({
    super.id,
    super.roomId,
    super.currentIndex,
    super.songs,
    super.ownerUserId,
    super.createdTimestamp,
    super.updatedTimestamp,
  });

  factory SharedQueueModel.fromJson(Map<String, dynamic> json) {
    final rawSongs = json['songs'] as List<dynamic>? ?? [];
    final parsedSongs = rawSongs.map((s) {
      if (s is Map<String, dynamic>) {
        return SongEntity(
          id: s['id'] as String? ?? 'song_1',
          title: s['title'] as String? ?? 'Sample Track',
          artist: s['artist'] as String? ?? 'SoulSync Audio',
          album: s['album'] as String? ?? 'SoulSync Essentials',
          duration: Duration(milliseconds: (s['duration_ms'] as num? ?? 180000).toInt()),
          assetPath: s['asset_path'] as String? ?? 'assets/music/sample_1.mp3',
        );
      }
      return const SongEntity(
        id: 'song_1',
        title: 'Sample Track',
        artist: 'SoulSync Audio',
        album: 'SoulSync Essentials',
        duration: Duration(minutes: 3),
        assetPath: 'assets/music/sample_1.mp3',
      );
    }).toList();

    return SharedQueueModel(
      id: json['id'] as String? ?? json['queue_id'] as String? ?? 'queue_default',
      roomId: json['room_id'] as String? ?? json['roomId'] as String? ?? 'soul_sync_room_default',
      currentIndex: (json['current_index'] as num? ?? json['currentIndex'] as num? ?? 0).toInt(),
      songs: parsedSongs,
      ownerUserId: json['owner_user_id'] as String? ?? json['ownerUserId'] as String?,
      createdTimestamp: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedTimestamp: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'current_index': currentIndex,
      'songs': songs.map((s) => {
        'id': s.id,
        'title': s.title,
        'artist': s.artist,
        'album': s.album,
        'duration_ms': s.duration.inMilliseconds,
        'asset_path': s.assetPath,
      }).toList(),
      'owner_user_id': ownerUserId,
      'created_at': createdTimestamp?.toIso8601String(),
      'updated_at': updatedTimestamp?.toIso8601String(),
    };
  }
}
