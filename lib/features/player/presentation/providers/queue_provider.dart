import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/player/domain/entities/queue_entity.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/queue/presentation/providers/queue_provider.dart';

class QueueNotifier extends StateNotifier<QueueEntity> {
  final Ref _ref;

  QueueNotifier(this._ref) : super(const QueueEntity());

  void setQueue(List<SongEntity> songs, int currentIndex) {
    if (songs.isEmpty) {
      state = const QueueEntity();
      return;
    }

    final safeIndex = currentIndex.clamp(0, songs.length - 1);
    final current = songs[safeIndex];
    final prev = songs.sublist(0, safeIndex);
    final upcoming = songs.sublist(safeIndex + 1);

    state = QueueEntity(
      currentSong: current,
      upcomingSongs: upcoming,
      previousSongs: prev,
    );
  }

  void addNext(SongEntity song) {
    final updatedUpcoming = [song, ...state.upcomingSongs];
    state = state.copyWith(upcomingSongs: updatedUpcoming);
    _ref.read(sharedQueueNotifierProvider.notifier).playNext(song);
  }

  void addToEnd(SongEntity song) {
    final updatedUpcoming = [...state.upcomingSongs, song];
    state = state.copyWith(upcomingSongs: updatedUpcoming);
    _ref.read(sharedQueueNotifierProvider.notifier).addSong(song);
  }

  void removeAt(int upcomingIndex) {
    if (upcomingIndex >= 0 && upcomingIndex < state.upcomingSongs.length) {
      final updated = List<SongEntity>.from(state.upcomingSongs)
        ..removeAt(upcomingIndex);
      state = state.copyWith(upcomingSongs: updated);
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final updated = List<SongEntity>.from(state.upcomingSongs);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(upcomingSongs: updated);
  }

  void clearQueue() {
    state = state.copyWith(upcomingSongs: []);
  }

  void playSongFromQueue(int upcomingIndex) {
    if (upcomingIndex >= 0 && upcomingIndex < state.upcomingSongs.length) {
      final selectedSong = state.upcomingSongs[upcomingIndex];
      final newUpcoming = state.upcomingSongs.sublist(upcomingIndex + 1);
      final newPrevious = [
        ...state.previousSongs,
        if (state.currentSong != null) state.currentSong!,
        ...state.upcomingSongs.sublist(0, upcomingIndex),
      ];

      state = QueueEntity(
        currentSong: selectedSong,
        upcomingSongs: newUpcoming,
        previousSongs: newPrevious,
      );

      final playerNotifier = _ref.read(playerNotifierProvider.notifier);
      playerNotifier.playSong(selectedSong);
    }
  }
}

final queueNotifierProvider =
    StateNotifierProvider<QueueNotifier, QueueEntity>((ref) {
  return QueueNotifier(ref);
});
