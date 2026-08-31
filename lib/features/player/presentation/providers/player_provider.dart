import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/app/bootstrap.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:soulsync/core/config/app_config.dart';

import 'package:soulsync/features/playback/domain/entities/playback_session_entity.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/data/repositories/music_repository_impl.dart';
import 'package:soulsync/features/player/data/services/audio_player_service.dart';
import 'package:soulsync/features/player/data/services/media_notification_service.dart';
import 'package:soulsync/features/player/domain/entities/playback_state_entity.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';
import 'package:soulsync/features/player/domain/usecases/get_local_songs_usecase.dart';
import 'package:soulsync/features/player/presentation/providers/queue_provider.dart';
import 'package:soulsync/features/player/presentation/providers/recently_played_provider.dart';
import 'package:soulsync/features/queue/presentation/providers/queue_provider.dart';

import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';

@immutable
class PlayerState {
  final SongEntity? currentSong;
  final List<SongEntity> queue;
  final int currentIndex;
  final PlaybackStateEntity playbackState;
  final bool isFavorite;

  const PlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.playbackState = const PlaybackStateEntity(),
    this.isFavorite = false,
  });

  PlayerState copyWith({
    SongEntity? currentSong,
    List<SongEntity>? queue,
    int? currentIndex,
    PlaybackStateEntity? playbackState,
    bool? isFavorite,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      playbackState: playbackState ?? this.playbackState,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayerService _audioService;
  final MediaNotificationService _notificationService;
  final GetLocalSongsUseCase _getLocalSongsUseCase;
  final Ref _ref;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<ja.PlayerState>? _playerStateSub;

  PlayerNotifier({
    required AudioPlayerService audioService,
    required MediaNotificationService notificationService,
    required GetLocalSongsUseCase getLocalSongsUseCase,
    required Ref ref,
  })  : _audioService = audioService,
        _notificationService = notificationService,
        _getLocalSongsUseCase = getLocalSongsUseCase,
        _ref = ref,
        super(const PlayerState()) {
    _initListeners();
    _loadInitialCatalog();
  }

  void _initListeners() {
    _positionSub = _audioService.positionStream.listen((pos) {
      state = state.copyWith(
        playbackState: state.playbackState.copyWith(position: pos),
      );
    });

    _durationSub = _audioService.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero) {
        state = state.copyWith(
          playbackState: state.playbackState.copyWith(duration: dur),
        );
      }
    });

    _playerStateSub = _audioService.playerStateStream.listen((pState) {
      final isPlaying = pState.playing;
      final isBuffering =
          pState.processingState == ja.ProcessingState.buffering;
      final isCompleted =
          pState.processingState == ja.ProcessingState.completed;

      final sessionState = _ref.read(playbackSessionNotifierProvider);
      final effectiveIsPlaying = (sessionState.hasActiveSession && sessionState.session != null)
          ? (sessionState.session?.playbackState == PlaybackLifecycleState.playing)
          : isPlaying;

      state = state.copyWith(
        playbackState: state.playbackState.copyWith(
          isPlaying: effectiveIsPlaying,
          isBuffering: isBuffering,
        ),
      );

      if (state.currentSong != null) {
        _notificationService.showPlaybackNotification(
          state.currentSong!,
          effectiveIsPlaying,
          position: state.playbackState.position,
          duration: state.playbackState.duration,
        );
      }

      // Only skip to next if the song completed naturally (position > 1s)
      if (isCompleted &&
          state.playbackState.position > const Duration(seconds: 1)) {
        debugPrint(
            '[PlayerNotifier] Song completed naturally. Processing auto-next.');

        final sessionState = _ref.read(playbackSessionNotifierProvider);
        final authUser = _ref.read(authNotifierProvider).user;
        final isHost = sessionState.session?.isHost(authUser?.id) ?? true;

        if (sessionState.hasActiveSession && !isHost) {
          debugPrint('[PlayerNotifier] Non-host partner awaiting host auto-next event.');
          return;
        }

        if (state.playbackState.repeatMode == RepeatModeEnum.one) {
          debugPrint('[PlayerNotifier] Repeat One enabled. Replaying current song.');
          seek(Duration.zero);
          _audioService.play();
        } else {
          skipToNext();
        }
      }
    });
  }

  Future<void> _loadInitialCatalog() async {
    try {
      final repo = _ref.read(musicRepositoryProvider);
      final songs = await repo.getLocalSongs();
      debugPrint('[PlayerNotifier] Loaded catalog: ${songs.length} songs');
      if (songs.isNotEmpty) {
        state = state.copyWith(
          queue: songs,
          currentIndex: 0,
          currentSong: null, // Keep idle until explicitly started!
          playbackState: const PlaybackStateEntity(isPlaying: false),
        );
        _ref.read(queueNotifierProvider.notifier).setQueue(songs, 0);
      }
    } catch (e) {
      debugPrint('[PlayerNotifier] Catalog load warning: $e');
    }
  }

  bool get isAudioEnginePlaying => _audioService.player.playing;

  int _playbackOpId = 0;

  Future<void> playSongById(String songId, {int initialPositionMs = 0}) async {
    final myOpId = ++_playbackOpId;
    debugPrint('[AudioEngine] Play button pressed (songId: $songId, pos: ${initialPositionMs}ms, opId: $myOpId)');

    // Ensure queue has full catalog
    if (state.queue.length <= 3) {
      await _loadInitialCatalog();
    }

    final queueIndex = state.queue.indexWhere((s) => s.id == songId);
    if (queueIndex != -1) {
      await playSongAtIndex(queueIndex, initialPositionMs: initialPositionMs, opId: myOpId);
      return;
    }

    final repo = _ref.read(musicRepositoryProvider);
    final song = await repo.getSongById(songId);
    if (myOpId != _playbackOpId) {
      debugPrint('[AudioEngine] Operation #$myOpId cancelled by newer operation #$_playbackOpId during repo lookup');
      return;
    }
    if (song != null) {
      debugPrint('[AudioEngine] Song resolved: ${song.title} (${song.id})');
      await playSong(song, initialPositionMs: initialPositionMs, opId: myOpId);
    }
  }

  Future<void> playSong(SongEntity song, {int initialPositionMs = 0, int? opId}) async {
    final myOpId = opId ?? ++_playbackOpId;
    debugPrint('[AudioEngine] Song resolved: ${song.title} (opId: $myOpId)');
    final index = state.queue.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      await playSongAtIndex(index, initialPositionMs: initialPositionMs, opId: myOpId);
    } else {
      final newQueue = [...state.queue, song];
      state = state.copyWith(queue: newQueue);
      await playSongAtIndex(newQueue.length - 1, initialPositionMs: initialPositionMs, opId: myOpId);
    }
  }

  Future<void> playSongAtIndex(int index, {int initialPositionMs = 0, int? opId}) async {
    final myOpId = opId ?? ++_playbackOpId;
    if (index < 0 || index >= state.queue.length) return;
    final song = state.queue[index];

    // If song is ALREADY playing, check if position seek is requested
    if (state.currentSong?.id == song.id && state.playbackState.isPlaying) {
      debugPrint('[AudioEngine] Song ${song.title} is already playing.');
      if (initialPositionMs > 1000) {
        await _audioService.seek(Duration(milliseconds: initialPositionMs));
      }
      return;
    }

    // If song is currentSong but paused and player is NOT idle, pre-seek then resume
    if (state.currentSong?.id == song.id &&
        _audioService.currentlyLoadedPath == song.assetPath &&
        _audioService.player.processingState != ja.ProcessingState.idle) {
      debugPrint('[AudioEngine] Song ${song.title} is already loaded. Pre-seeking to ${initialPositionMs}ms then resuming (opId: $myOpId).');
      try {
        await _audioService.seek(Duration(milliseconds: initialPositionMs));
        final sessionState = _ref.read(playbackSessionNotifierProvider);
        if (sessionState.hasActiveSession &&
            sessionState.session?.playbackState == PlaybackLifecycleState.paused) {
          debugPrint('[AudioEngine] Aborting _audioService.play() because room session is currently PAUSED.');
          return;
        }
        if (myOpId != _playbackOpId) {
          debugPrint('[AudioEngine] Aborting play() because operation #$myOpId was cancelled by #$_playbackOpId');
          return;
        }
        await _audioService.play();
        state = state.copyWith(
          playbackState: state.playbackState.copyWith(
            isPlaying: true,
            position: Duration(milliseconds: initialPositionMs),
          ),
        );
        _notificationService.showPlaybackNotification(song, true);
        debugPrint('[AudioEngine] Playback resumed cleanly');
      } catch (e) {
        debugPrint('[AudioEngine] Error resuming song at index $index: $e');
      }
      return;
    }

    debugPrint(
        '[AudioEngine] Loading asset: ${song.assetPath} for track ${song.title} (opId: $myOpId)');

    state = state.copyWith(
      currentIndex: index,
      currentSong: song,
      isFavorite: song.isFavorite,
      playbackState: state.playbackState.copyWith(
        isBuffering: true,
        duration: song.duration,
      ),
    );

    _ref.read(queueNotifierProvider.notifier).setQueue(state.queue, index);
    _ref.read(recentlyPlayedNotifierProvider.notifier).recordSongPlayed(song);

    try {
      final dur = await _audioService.loadAsset(song.assetPath);
      _preloadNextSong(index);
      if (myOpId != _playbackOpId) {
        debugPrint('[AudioEngine] Aborting load/play because operation #$myOpId was cancelled by #$_playbackOpId');
        return;
      }
      if (dur != null && dur > Duration.zero) {
        state = state.copyWith(
          playbackState: state.playbackState.copyWith(duration: dur),
        );
      }
      if (initialPositionMs > 0) {
        debugPrint('[AudioEngine] Pre-seeking asset to ${initialPositionMs}ms before play');
        await _audioService.seek(Duration(milliseconds: initialPositionMs));
      }
      final currentSessionState = _ref.read(playbackSessionNotifierProvider);
      if (SoulSyncAudioHandler.instance.isRemoteSyncing &&
          currentSessionState.hasActiveSession &&
          currentSessionState.session?.playbackState == PlaybackLifecycleState.paused) {
        debugPrint('[AudioEngine] Aborting _audioService.play() due to remote PAUSE event.');
        return;
      }
      if (myOpId != _playbackOpId) {
        debugPrint('[AudioEngine] Aborting play() because operation #$myOpId was cancelled by #$_playbackOpId');
        return;
      }
      await _audioService.play();
      if (myOpId != _playbackOpId) {
        debugPrint('[AudioEngine] Aborting play() state update because operation #$myOpId was superseded by #$_playbackOpId');
        return;
      }
      state = state.copyWith(
        playbackState: state.playbackState.copyWith(
          isPlaying: true,
          position: Duration(milliseconds: initialPositionMs),
        ),
      );
      _notificationService.showPlaybackNotification(
        song,
        true,
        position: state.playbackState.position,
        duration: song.duration,
      );
      debugPrint('[AudioEngine] Playback started cleanly: ${song.title}');
    } catch (e) {
      debugPrint('[AudioEngine] Error playing song at index $index: $e');
      state = state.copyWith(
        playbackState: state.playbackState.copyWith(
          isPlaying: false,
          isBuffering: false,
        ),
      );
    }
  }

  Future<void> resumeSong() async {
    final myOpId = ++_playbackOpId;
    debugPrint('[AudioEngine] Playback resumed requested (opId: $myOpId)');
    if (state.currentSong == null || _audioService.currentlyLoadedPath == null) {
      debugPrint('[AudioEngine] No song loaded currently. Initializing first song in queue.');
      final index = state.currentIndex >= 0 ? state.currentIndex : 0;
      await playSongAtIndex(index, opId: myOpId);
      return;
    }
    final sessionState = _ref.read(playbackSessionNotifierProvider);
    if (sessionState.hasActiveSession &&
        sessionState.session?.playbackState == PlaybackLifecycleState.paused) {
      debugPrint('[AudioEngine] Aborting resumeSong because room session is currently PAUSED.');
      return;
    }
    if (myOpId != _playbackOpId) {
      debugPrint('[AudioEngine] Aborting resumeSong because operation #$myOpId was cancelled by #$_playbackOpId');
      return;
    }
    await _audioService.play();
    if (myOpId != _playbackOpId) {
      debugPrint('[AudioEngine] Aborting resumeSong state update because operation #$myOpId was superseded by #$_playbackOpId');
      return;
    }
    state = state.copyWith(
      playbackState: state.playbackState.copyWith(isPlaying: true),
    );
    if (state.currentSong != null) {
      _notificationService.showPlaybackNotification(
        state.currentSong!,
        true,
        position: state.playbackState.position,
        duration: state.playbackState.duration,
      );
    }
    debugPrint('[AudioEngine] Playback resumed');
  }

  Future<void> pauseSong() async {
    final myOpId = ++_playbackOpId;
    debugPrint('[DIAGNOSTIC-1B] PlayerNotifier.pauseSong() called (opId: $myOpId). Current local playing: ${state.playbackState.isPlaying}');
    await _audioService.pause();
    if (myOpId != _playbackOpId) {
      debugPrint('[AudioEngine] Aborting pauseSong state update because operation #$myOpId was superseded by #$_playbackOpId');
      return;
    }
    state = state.copyWith(
      playbackState: state.playbackState.copyWith(isPlaying: false),
    );
    if (state.currentSong != null) {
      _notificationService.showPlaybackNotification(
        state.currentSong!,
        false,
        position: state.playbackState.position,
        duration: state.playbackState.duration,
      );
    }
    debugPrint('[DIAGNOSTIC-1B] PlayerNotifier.pauseSong() completed (opId: $myOpId). New local playing: false');
  }

  DateTime _lastToggleTime = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> togglePlayPause() async {
    final now = DateTime.now();
    final diffMs = now.difference(_lastToggleTime).inMilliseconds;
    debugPrint('[DIAGNOSTIC-1A] togglePlayPause called. diffSinceLastToggle: ${diffMs}ms');
    _lastToggleTime = now;

    final sessionState = _ref.read(playbackSessionNotifierProvider);

    final bool isCurrentlyPlaying;
    if (sessionState.hasActiveSession) {
      isCurrentlyPlaying = sessionState.session?.playbackState == PlaybackLifecycleState.playing;
    } else {
      isCurrentlyPlaying = state.playbackState.isPlaying || _audioService.player.playing;
    }

    debugPrint('[DIAGNOSTIC-1A] togglePlayPause decision state -> isCurrentlyPlaying: $isCurrentlyPlaying (localPlaying: ${state.playbackState.isPlaying}, sessionState: ${sessionState.session?.playbackState}, enginePlaying: ${_audioService.player.playing})');

    if (sessionState.hasActiveSession) {
      final sessionNotifier = _ref.read(playbackSessionNotifierProvider.notifier);
      if (isCurrentlyPlaying) {
        debugPrint('[DIAGNOSTIC-1A] Decision: Calling sessionNotifier.pause(pos: ${state.playbackState.position.inMilliseconds}ms)');
        await sessionNotifier.pause(positionMs: state.playbackState.position.inMilliseconds);
      } else {
        final targetSongId = state.currentSong?.id ?? sessionState.session?.currentSongId ?? 'song_1';
        debugPrint('[DIAGNOSTIC-1A] Decision: Calling sessionNotifier.play(targetSongId: $targetSongId, pos: ${state.playbackState.position.inMilliseconds}ms)');
        await sessionNotifier.play(
          songId: targetSongId,
          positionMs: state.playbackState.position.inMilliseconds,
        );
      }
      return;
    }

    if (state.currentSong == null && state.queue.isNotEmpty) {
      await playSongAtIndex(0);
      return;
    }

    if (state.playbackState.isPlaying) {
      await pauseSong();
    } else {
      await resumeSong();
    }
  }

  Future<void> seekLocal(Duration position) async {
    try {
      await _audioService.seek(position);
      state = state.copyWith(
        playbackState: state.playbackState.copyWith(position: position),
      );
      if (state.currentSong != null) {
        _notificationService.showPlaybackNotification(
          state.currentSong!,
          state.playbackState.isPlaying,
          position: position,
          duration: state.playbackState.duration,
        );
      }
    } catch (e) {
      debugPrint('[AudioEngine] Error seeking local: $e');
    }
  }

  Future<void> seek(Duration position) async {
    final sessionState = _ref.read(playbackSessionNotifierProvider);
    final roomState = _ref.read(roomNotifierProvider);

    if (sessionState.hasActiveSession || roomState.room != null) {
      await _ref.read(playbackSessionNotifierProvider.notifier).seek(positionMs: position.inMilliseconds);
    } else {
      await seekLocal(position);
    }
  }

  Future<void> seekTo(Duration position) => seek(position);

  SongEntity? getNextSong() {
    if (state.queue.isEmpty) return null;
    int nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.queue.length) {
      nextIndex = 0;
    }
    return state.queue[nextIndex];
  }

  SongEntity? getPreviousSong() {
    if (state.queue.isEmpty) return null;
    int prevIndex = state.currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = state.queue.length - 1;
    }
    return state.queue[prevIndex];
  }

  Future<void> skipToNext() async {
    if (state.queue.length <= 3) {
      await _loadInitialCatalog();
    }
    final queue = state.queue;
    if (queue.isEmpty) return;
    final currIndex = state.currentIndex;

    int nextIndex;
    if (state.playbackState.isShuffle && queue.length > 1) {
      final rand = Random();
      do {
        nextIndex = rand.nextInt(queue.length);
      } while (nextIndex == currIndex);
    } else {
      nextIndex = currIndex + 1;
      if (nextIndex >= queue.length) {
        nextIndex = 0;
      }
    }

    final nextSong = queue[nextIndex];
    final sessionState = _ref.read(playbackSessionNotifierProvider);
    if (sessionState.hasActiveSession) {
      _ref.read(playbackSessionNotifierProvider.notifier).play(songId: nextSong.id, positionMs: 0);
    }
    await playSongAtIndex(nextIndex);
  }

  Future<void> skipToPrevious() async {
    final queue = state.queue;
    if (queue.isEmpty) return;
    final currIndex = state.currentIndex;

    int prevIndex;
    if (state.playbackState.isShuffle && queue.length > 1) {
      final rand = Random();
      do {
        prevIndex = rand.nextInt(queue.length);
      } while (prevIndex == currIndex);
    } else {
      prevIndex = currIndex - 1;
      if (prevIndex < 0) {
        prevIndex = queue.length - 1;
      }
    }

    final prevSong = queue[prevIndex];
    final sessionState = _ref.read(playbackSessionNotifierProvider);
    if (sessionState.hasActiveSession) {
      _ref.read(playbackSessionNotifierProvider.notifier).play(songId: prevSong.id, positionMs: 0);
    }
    await playSongAtIndex(prevIndex);
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(
      playbackState: state.playbackState.copyWith(volume: volume),
    );
    await _audioService.setVolume(volume);
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(
      playbackState: state.playbackState.copyWith(speed: speed),
    );
    await _audioService.setSpeed(speed);
  }

  Future<void> toggleShuffle() async {
    final newShuffle = !state.playbackState.isShuffle;
    state = state.copyWith(
      playbackState: state.playbackState.copyWith(isShuffle: newShuffle),
    );
    await _audioService.setShuffleModeEnabled(newShuffle);

    final sessionState = _ref.read(playbackSessionNotifierProvider);
    if (sessionState.hasActiveSession) {
      _ref.read(webSocketServiceProvider).send({
        'type': 'playback_settings',
        'event': 'playback_settings',
        'isShuffle': newShuffle,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> toggleRepeat() async {
    final currentMode = state.playbackState.repeatMode;
    RepeatModeEnum newMode;
    ja.LoopMode justAudioMode;

    switch (currentMode) {
      case RepeatModeEnum.off:
        newMode = RepeatModeEnum.all;
        justAudioMode = ja.LoopMode.all;
        break;
      case RepeatModeEnum.all:
        newMode = RepeatModeEnum.one;
        justAudioMode = ja.LoopMode.one;
        break;
      case RepeatModeEnum.one:
        newMode = RepeatModeEnum.off;
        justAudioMode = ja.LoopMode.off;
        break;
    }

    state = state.copyWith(
      playbackState: state.playbackState.copyWith(repeatMode: newMode),
    );
    await _audioService.setLoopMode(justAudioMode);
  }

  Future<void> toggleFavorite() async {
    final song = state.currentSong;
    if (song != null) {
      final repo = _ref.read(musicRepositoryProvider);
      await repo.toggleFavorite(song.id);
      state = state.copyWith(isFavorite: !state.isFavorite);
    }
  }

  void addToQueue(SongEntity song) {
    state = state.copyWith(queue: [...state.queue, song]);
    _ref.read(queueNotifierProvider.notifier).addToEnd(song);
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= state.queue.length) return;
    final newQueue = List<SongEntity>.from(state.queue)..removeAt(index);
    state = state.copyWith(queue: newQueue);
  }

  void _preloadNextSong(int currentIndex) {
    // Disabled competing Dio HTTP stream request to avoid Cloudflare Tunnel socket contention
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

// Providers
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return LocalMusicRepositoryImpl(config: config);
});

final getLocalSongsUseCaseProvider = Provider<GetLocalSongsUseCase>((ref) {
  final repo = ref.watch(musicRepositoryProvider);
  return GetLocalSongsUseCase(repo);
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final audioHandlerProvider = Provider<AudioHandler?>((ref) {
  SoulSyncAudioHandler.instance.attachRef(ref);
  return gAudioHandler;
});

final mediaNotificationServiceProvider =
    Provider<MediaNotificationService>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return MediaNotificationService(handler);
});

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(
    audioService: ref.watch(audioPlayerServiceProvider),
    notificationService: ref.watch(mediaNotificationServiceProvider),
    getLocalSongsUseCase: ref.watch(getLocalSongsUseCaseProvider),
    ref: ref,
  );
});
