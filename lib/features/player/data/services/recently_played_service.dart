import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulsync/features/player/data/models/song_model.dart';
import 'package:soulsync/features/player/domain/entities/recently_played_item.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

class RecentlyPlayedService {
  static const _key = 'soulsync_recently_played_list';
  static const _maxItems = 50;

  Future<List<RecentlyPlayedItem>> getRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) {
        final songMap = item['song'] as Map<String, dynamic>;
        final song = SongModel.fromJson(songMap);
        final date = DateTime.parse(item['playedAt'] as String);
        final count = item['playCount'] as int? ?? 1;
        return RecentlyPlayedItem(song: song, playedAt: date, playCount: count);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> recordSongPlayed(SongEntity song) async {
    try {
      final current = await getRecentlyPlayed();
      final index = current.indexWhere((item) => item.song.id == song.id);

      int playCount = 1;
      if (index != -1) {
        playCount = current[index].playCount + 1;
        current.removeAt(index);
      }

      current.insert(
        0,
        RecentlyPlayedItem(
          song: song,
          playedAt: DateTime.now(),
          playCount: playCount,
        ),
      );

      if (current.length > _maxItems) {
        current.removeRange(_maxItems, current.length);
      }

      final jsonList = current.map((item) {
        final songModel = SongModel(
          id: item.song.id,
          title: item.song.title,
          artist: item.song.artist,
          album: item.song.album,
          albumId: item.song.albumId,
          artistId: item.song.artistId,
          artworkUrl: item.song.artworkUrl,
          assetPath: item.song.assetPath,
          duration: item.song.duration,
          size: item.song.size,
          isFavorite: item.song.isFavorite,
        );
        return {
          'song': songModel.toJson(),
          'playedAt': item.playedAt.toIso8601String(),
          'playCount': item.playCount,
        };
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (_) {}
  }
}
