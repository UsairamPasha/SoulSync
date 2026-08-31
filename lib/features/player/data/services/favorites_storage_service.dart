import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorageService {
  static const _key = 'soulsync_favorite_song_ids';

  Future<Set<String>> getFavoriteSongIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<bool> toggleFavorite(String songId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = (prefs.getStringList(_key) ?? []).toSet();

      bool isFav;
      if (favorites.contains(songId)) {
        favorites.remove(songId);
        isFav = false;
      } else {
        favorites.add(songId);
        isFav = true;
      }

      await prefs.setStringList(_key, favorites.toList());
      return isFav;
    } catch (_) {
      return false;
    }
  }
}
