import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soulsync/app/bootstrap.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/data/services/notification_service_stub.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';

/// AudioHandler forwarding system media controls (Lock Screen, Notification, Bluetooth) to Room-Synced PlayerNotifier.
class SoulSyncAudioHandler extends BaseAudioHandler with SeekHandler {
  static SoulSyncAudioHandler? _instance;
  DateTime _lastMediaActionTime = DateTime.fromMillisecondsSinceEpoch(0);

  static SoulSyncAudioHandler get instance {
    _instance ??= SoulSyncAudioHandler();
    return _instance!;
  }

  Ref? _ref;

  SoulSyncAudioHandler([this._ref]) {
    _instance = this;
  }

  void attachRef(Ref ref) {
    _ref = ref;
  }

  bool isRemoteSyncing = false;

  bool _isDebounced() {
    final now = DateTime.now();
    if (now.difference(_lastMediaActionTime).inMilliseconds < 400) {
      debugPrint('[SoulSyncAudioHandler] Debouncing duplicate system media action (<400ms)');
      return true;
    }
    _lastMediaActionTime = now;
    return false;
  }

  Future<void> clickMediaButton(MediaButton button) async {
    debugPrint('[SoulSyncAudioHandler] System media action: clickMediaButton ($button)');
    if (isRemoteSyncing || _isDebounced()) return;
    if (_ref != null) {
      final playerNotifier = _ref!.read(playerNotifierProvider.notifier);
      switch (button) {
        case MediaButton.media:
          await playerNotifier.togglePlayPause();
          break;
        case MediaButton.next:
          await playerNotifier.skipToNext();
          break;
        case MediaButton.previous:
          await playerNotifier.skipToPrevious();
          break;
      }
    }
  }

  @override
  Future<void> play() async {
    debugPrint('[SoulSyncAudioHandler] System media action: PLAY');
    if (isRemoteSyncing || _isDebounced()) {
      debugPrint('[SoulSyncAudioHandler] Skipping PLAY system media action (remote syncing or debounced)');
      return;
    }
    if (_ref != null) {
      final sessionState = _ref!.read(playbackSessionNotifierProvider);
      final roomState = _ref!.read(roomNotifierProvider);
      final playerState = _ref!.read(playerNotifierProvider);

      if (sessionState.hasActiveSession || roomState.room != null) {
        final sessionNotifier = _ref!.read(playbackSessionNotifierProvider.notifier);
        final targetSongId = playerState.currentSong?.id ?? sessionState.session?.currentSongId ?? 'song_1';
        await sessionNotifier.play(
          songId: targetSongId,
          positionMs: playerState.playbackState.position.inMilliseconds,
        );
      } else {
        await _ref!.read(playerNotifierProvider.notifier).resumeSong();
      }
    }
  }

  @override
  Future<void> pause() async {
    debugPrint('[SoulSyncAudioHandler] System media action: PAUSE');
    if (isRemoteSyncing || _isDebounced()) {
      debugPrint('[SoulSyncAudioHandler] Skipping PAUSE system media action (remote syncing or debounced)');
      return;
    }
    if (_ref != null) {
      final sessionState = _ref!.read(playbackSessionNotifierProvider);
      final roomState = _ref!.read(roomNotifierProvider);
      final playerState = _ref!.read(playerNotifierProvider);

      if (sessionState.hasActiveSession || roomState.room != null) {
        final sessionNotifier = _ref!.read(playbackSessionNotifierProvider.notifier);
        await sessionNotifier.pause(positionMs: playerState.playbackState.position.inMilliseconds);
      } else {
        await _ref!.read(playerNotifierProvider.notifier).pauseSong();
      }
    }
  }

  @override
  Future<void> skipToNext() async {
    debugPrint('[SoulSyncAudioHandler] System media action: NEXT');
    if (_ref != null) {
      await _ref!.read(playerNotifierProvider.notifier).skipToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    debugPrint('[SoulSyncAudioHandler] System media action: PREVIOUS');
    if (_ref != null) {
      await _ref!.read(playerNotifierProvider.notifier).skipToPrevious();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    debugPrint('[SoulSyncAudioHandler] System media action: SEEK to $position');
    if (_ref != null) {
      await _ref!.read(playerNotifierProvider.notifier).seekTo(position);
    }
  }

  @override
  Future<void> fastForward([Duration interval = const Duration(seconds: 10)]) async {
    debugPrint('[SoulSyncAudioHandler] System media action: FAST FORWARD ($interval)');
    if (_ref != null) {
      final playerState = _ref!.read(playerNotifierProvider);
      final currentPos = playerState.playbackState.position;
      final targetPos = currentPos + interval;
      await seek(targetPos);
    }
  }

  @override
  Future<void> rewind([Duration interval = const Duration(seconds: 10)]) async {
    debugPrint('[SoulSyncAudioHandler] System media action: REWIND ($interval)');
    if (_ref != null) {
      final playerState = _ref!.read(playerNotifierProvider);
      final currentPos = playerState.playbackState.position;
      final targetPos = currentPos - interval;
      final validPos = targetPos < Duration.zero ? Duration.zero : targetPos;
      await seek(validPos);
    }
  }
}

/// Production MediaNotificationService integrating Android MediaSession & iOS MPNowPlayingInfoCenter.
class MediaNotificationService implements NotificationService {
  bool _isShowing = false;
  SongEntity? _currentSong;
  bool _isPlaying = false;
  int? _lastPosSeconds;

  MediaNotificationService([AudioHandler? handler]);

  bool get isShowing => _isShowing;
  SongEntity? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  @override
  Future<void> showPlaybackNotification(SongEntity song, bool isPlaying,
      {Duration? position, Duration? duration}) async {
    final songDuration = duration ?? song.duration;
    final currentPos = position ?? Duration.zero;
    final posSeconds = currentPos.inSeconds;

    if (_isShowing &&
        _currentSong?.id == song.id &&
        _isPlaying == isPlaying &&
        _lastPosSeconds == posSeconds) {
      return;
    }

    _isShowing = true;
    _currentSong = song;
    _isPlaying = isPlaying;
    _lastPosSeconds = posSeconds;

    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {
      debugPrint('[MediaNotificationService] Permission request notice: $e');
    }

    final handler = SoulSyncAudioHandler.instance;

    debugPrint(
      '[MediaNotificationService] Native Media Notification: "${song.title}" by ${song.artist} [${isPlaying ? "PLAYING" : "PAUSED"}] (gAudioHandler: ${gAudioHandler != null ? "ACTIVE" : "NULL"})',
    );

    final mediaItem = MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: songDuration,
    );

    final playbackState = PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.fastForward,
        MediaAction.rewind,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.ready,
      playing: isPlaying,
      speed: isPlaying ? 1.0 : 0.0,
      updatePosition: currentPos,
      updateTime: DateTime.now(),
    );

    try {
      handler.mediaItem.add(mediaItem);
      handler.playbackState.add(playbackState);
      debugPrint('[MediaNotificationService] Successfully updated SoulSyncAudioHandler mediaItem & playbackState streams! (Playing: $isPlaying)');
    } catch (e, st) {
      debugPrint('[MediaNotificationService] Error updating handler streams: $e\n$st');
    }
  }

  @override
  Future<void> clearNotification() async {
    _isShowing = false;
    _currentSong = null;
    _isPlaying = false;
    _lastPosSeconds = null;

    try {
      final handler = SoulSyncAudioHandler.instance;
      handler.playbackState.add(PlaybackState(
        controls: const [],
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
    } catch (_) {}

    debugPrint('[MediaNotificationService] Media notification dismissed.');
  }
}
