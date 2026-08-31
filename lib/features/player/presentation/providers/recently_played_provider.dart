import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/player/data/services/recently_played_service.dart';
import 'package:soulsync/features/player/domain/entities/recently_played_item.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

class RecentlyPlayedNotifier extends StateNotifier<List<RecentlyPlayedItem>> {
  final RecentlyPlayedService _service;

  RecentlyPlayedNotifier(this._service) : super([]) {
    load();
  }

  Future<void> load() async {
    final list = await _service.getRecentlyPlayed();
    state = list;
  }

  Future<void> recordSongPlayed(SongEntity song) async {
    await _service.recordSongPlayed(song);
    await load();
  }
}

final recentlyPlayedServiceProvider = Provider<RecentlyPlayedService>((ref) {
  return RecentlyPlayedService();
});

final recentlyPlayedNotifierProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<RecentlyPlayedItem>>(
        (ref) {
  final service = ref.watch(recentlyPlayedServiceProvider);
  return RecentlyPlayedNotifier(service);
});
