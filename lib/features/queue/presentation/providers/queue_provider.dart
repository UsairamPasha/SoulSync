import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/logger/app_logger.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/providers/queue_provider.dart' as player_queue;
import 'package:soulsync/features/queue/data/models/shared_queue_model.dart';
import 'package:soulsync/features/queue/data/repositories/queue_repository_impl.dart';
import 'package:soulsync/features/queue/domain/entities/shared_queue_entity.dart';
import 'package:soulsync/features/queue/domain/repositories/queue_repository.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/realtime/services/web_socket_service.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';

enum QueueLifecycleState {
  noQueue,
  queueCreated,
  songsAdded,
  ready,
  playing,
  queueUpdated,
  queueFinished,
  empty,
}

@immutable
class SharedQueueState {
  final SharedQueueEntity? queue;
  final QueueLifecycleState lifecycleState;
  final bool isLoading;
  final String? errorMessage;

  const SharedQueueState({
    this.queue,
    this.lifecycleState = QueueLifecycleState.noQueue,
    this.isLoading = false,
    this.errorMessage,
  });

  SharedQueueState copyWith({
    SharedQueueEntity? queue,
    QueueLifecycleState? lifecycleState,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SharedQueueState(
      queue: queue ?? this.queue,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SharedQueueNotifier extends StateNotifier<SharedQueueState> {
  final QueueRepository _repository;
  final WebSocketService _wsService;
  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  SharedQueueNotifier(this._repository, this._wsService, this._ref)
      : super(const SharedQueueState()) {
    _initWsListener();
  }

  void _initWsListener() {
    _wsSub = _wsService.messageStream.listen((data) {
      final type = data['type'] as String?;
      final event = data['event'] as String? ?? data['payload']?['event'] as String?;
      final eventType = type ?? event ?? '';

      if (eventType.startsWith('queue_') || eventType == 'queue_updated') {
        _handleWsQueueEvent(data);
      }
    });
  }

  void _handleWsQueueEvent(Map<String, dynamic> data) {
    AppLogger.debug('[SharedQueueNotifier] WS Queue Event: $data');
    final rawQueue = data['queue'] as Map<String, dynamic>? ?? data;
    try {
      final updatedQueue = SharedQueueModel.fromJson(rawQueue);
      final isFinished = updatedQueue.songs.isEmpty || updatedQueue.currentIndex >= updatedQueue.songs.length;
      final newState = updatedQueue.songs.isEmpty
          ? QueueLifecycleState.empty
          : (isFinished ? QueueLifecycleState.queueFinished : QueueLifecycleState.queueUpdated);

      state = state.copyWith(
        queue: updatedQueue,
        lifecycleState: newState,
        isLoading: false,
      );

      // Sync local PlayerNotifier queue with shared queue
      final playerNotifier = _ref.read(playerNotifierProvider.notifier);
      final queueNotifier = _ref.read(player_queue.queueNotifierProvider.notifier);
      queueNotifier.setQueue(updatedQueue.songs, updatedQueue.currentIndex);

      if (isFinished && updatedQueue.songs.isNotEmpty) {
        debugPrint('[SharedQueueNotifier] Queue finished. Stopping audio playback and entering waiting state.');
        playerNotifier.pauseSong();
      }
    } catch (e) {
      debugPrint('[SharedQueueNotifier] Parse WS queue event error: $e');
    }
  }

  String getEffectiveRoomId() {
    final sessionRoomId = _ref.read(playbackSessionNotifierProvider).session?.roomId;
    if (sessionRoomId != null && sessionRoomId.isNotEmpty) {
      return sessionRoomId;
    }
    final roomRoomId = _ref.read(roomNotifierProvider).room?.id;
    if (roomRoomId != null && roomRoomId.isNotEmpty) {
      return roomRoomId;
    }
    final queueRoomId = state.queue?.roomId;
    if (queueRoomId != null && queueRoomId.isNotEmpty) {
      return queueRoomId;
    }
    return 'soul_sync_room_default';
  }

  Future<void> loadQueue([String? roomId]) async {
    final activeRoomId = roomId ?? getEffectiveRoomId();
    state = state.copyWith(isLoading: true, errorMessage: null);

    final loaded = await _repository.getQueue(activeRoomId);
    if (loaded != null) {
      final isFinished = loaded.songs.isEmpty || loaded.currentIndex >= loaded.songs.length;
      final lifecycle = loaded.songs.isEmpty
          ? QueueLifecycleState.empty
          : (isFinished ? QueueLifecycleState.queueFinished : QueueLifecycleState.ready);

      state = state.copyWith(
        queue: loaded,
        lifecycleState: lifecycle,
        isLoading: false,
      );

      _ref.read(player_queue.queueNotifierProvider.notifier).setQueue(loaded.songs, loaded.currentIndex);
    } else {
      state = state.copyWith(
        lifecycleState: QueueLifecycleState.noQueue,
        isLoading: false,
      );
    }
  }

  Future<bool> addSong(SongEntity song) async {
    final wasEmpty = state.queue == null || state.queue!.songs.isEmpty;
    final roomId = getEffectiveRoomId();
    final updated = await _repository.addSong(roomId, song);
    if (updated != null) {
      state = state.copyWith(
        queue: updated,
        lifecycleState: QueueLifecycleState.songsAdded,
      );
      _ref.read(player_queue.queueNotifierProvider.notifier).setQueue(updated.songs, updated.currentIndex);
      if (wasEmpty) {
        final sessionState = _ref.read(playbackSessionNotifierProvider);
        if (sessionState.hasActiveSession) {
          await _ref.read(playbackSessionNotifierProvider.notifier).play(songId: song.id, positionMs: 0);
        } else {
          await _ref.read(playerNotifierProvider.notifier).playSong(song);
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> playNext(SongEntity song) async {
    final roomId = getEffectiveRoomId();
    final updated = await _repository.playNext(roomId, song);
    if (updated != null) {
      state = state.copyWith(
        queue: updated,
        lifecycleState: QueueLifecycleState.queueUpdated,
      );
      _ref.read(player_queue.queueNotifierProvider.notifier).setQueue(updated.songs, updated.currentIndex);
      return true;
    }
    return false;
  }

  Future<bool> reorderQueue(int oldIndex, int newIndex) async {
    final roomId = getEffectiveRoomId();
    final updated = await _repository.reorderQueue(roomId, oldIndex, newIndex);
    if (updated != null) {
      state = state.copyWith(
        queue: updated,
        lifecycleState: QueueLifecycleState.queueUpdated,
      );
      _ref.read(player_queue.queueNotifierProvider.notifier).setQueue(updated.songs, updated.currentIndex);
      return true;
    }
    return false;
  }

  Future<bool> removeSong(int index) async {
    final sessionState = _ref.read(playbackSessionNotifierProvider);
    final activeSongId = sessionState.session?.currentSongId;
    final activeIndex = state.queue?.effectiveIndexForId(activeSongId) ?? state.queue?.currentIndex ?? 0;
    final wasActivePlayingSong = (index == activeIndex);

    final roomId = getEffectiveRoomId();
    final updated = await _repository.removeSong(roomId, index);
    if (updated != null) {
      final isFinished = updated.songs.isEmpty || updated.currentIndex >= updated.songs.length;
      final lifecycle = updated.songs.isEmpty
          ? QueueLifecycleState.empty
          : (isFinished ? QueueLifecycleState.queueFinished : QueueLifecycleState.queueUpdated);

      state = state.copyWith(
        queue: updated,
        lifecycleState: lifecycle,
      );
      _ref.read(player_queue.queueNotifierProvider.notifier).setQueue(updated.songs, updated.currentIndex);

      if (wasActivePlayingSong) {
        if (updated.songs.isNotEmpty) {
          final nextIndex = updated.currentIndex.clamp(0, updated.songs.length - 1);
          final nextSong = updated.songs[nextIndex];
          if (sessionState.hasActiveSession) {
            await _ref.read(playbackSessionNotifierProvider.notifier).play(songId: nextSong.id, positionMs: 0);
          } else {
            await _ref.read(playerNotifierProvider.notifier).playSong(nextSong);
          }
        } else {
          _ref.read(playerNotifierProvider.notifier).pauseSong();
        }
      }

      return true;
    }
    return false;
  }

  Future<bool> clearQueue() async {
    final roomId = getEffectiveRoomId();
    final updated = await _repository.clearQueue(roomId);
    if (updated != null) {
      state = state.copyWith(
        queue: updated,
        lifecycleState: QueueLifecycleState.empty,
      );
      _ref.read(player_queue.queueNotifierProvider.notifier).clearQueue();
      _ref.read(playerNotifierProvider.notifier).pauseSong();
      return true;
    }
    return false;
  }

  Future<bool> selectSongIndex(int index) async {
    final roomId = getEffectiveRoomId();
    
    // 1. Optimistic Local Update & Instant Playback Trigger
    final playerQueue = _ref.read(playerNotifierProvider).queue;
    final queueSongs = (state.queue != null && state.queue!.songs.isNotEmpty)
        ? state.queue!.songs
        : playerQueue;

    if (index >= 0 && index < queueSongs.length) {
      final song = queueSongs[index];
      if (state.queue != null && state.queue!.songs.isNotEmpty) {
        final updatedLocal = state.queue!.copyWith(currentIndex: index);
        state = state.copyWith(queue: updatedLocal, lifecycleState: QueueLifecycleState.ready);
      }
      _ref.read(player_queue.queueNotifierProvider.notifier).setQueue(queueSongs, index);

      final sessionState = _ref.read(playbackSessionNotifierProvider);
      if (sessionState.hasActiveSession) {
        await _ref.read(playbackSessionNotifierProvider.notifier).play(songId: song.id, positionMs: 0);
      } else {
        await _ref.read(playerNotifierProvider.notifier).playSong(song);
      }
    }

    Future.microtask(() async {
      try {
        await _repository.selectSongIndex(roomId, index);
      } catch (e) {
        debugPrint('[SharedQueueNotifier] Async selectSongIndex warning: $e');
      }
    });
    return true;
  }

  void setCurrentIndexForSongId(String songId) {
    if (state.queue == null || state.queue!.songs.isEmpty) return;
    final idx = state.queue!.songs.indexWhere((s) => s.id == songId);
    if (idx != -1 && idx != state.queue!.currentIndex) {
      final updated = state.queue!.copyWith(currentIndex: idx);
      state = state.copyWith(queue: updated);
      _ref.read(player_queue.queueNotifierProvider.notifier).setQueue(updated.songs, idx);
    }
  }

  Future<void> recoverQueue() async {
    final roomId = getEffectiveRoomId();
    await _repository.syncQueue(roomId);
    await loadQueue(roomId);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }
}

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return QueueRepositoryImpl(dioClient);
});

final sharedQueueNotifierProvider =
    StateNotifierProvider<SharedQueueNotifier, SharedQueueState>((ref) {
  final repo = ref.watch(queueRepositoryProvider);
  final ws = ref.watch(webSocketServiceProvider);
  final notifier = SharedQueueNotifier(repo, ws, ref);
  notifier.loadQueue();
  return notifier;
});
