import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:just_audio/just_audio.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';
import 'package:soulsync/app/router.dart';
import 'package:soulsync/core/logger/app_logger.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/playback/data/models/playback_session_model.dart';
import 'package:soulsync/features/playback/data/repositories/playback_api_repository_impl.dart';
import 'package:soulsync/features/playback/domain/entities/playback_session_entity.dart';
import 'package:soulsync/features/playback/domain/repositories/playback_repository.dart';
import 'package:soulsync/features/player/presentation/providers/playback_settings_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/realtime/services/web_socket_service.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';
import 'package:soulsync/features/queue/presentation/providers/queue_provider.dart';
import 'package:soulsync/features/player/data/services/media_notification_service.dart';

@immutable
class PlaybackSessionState {
  final PlaybackSessionEntity? session;
  final bool isLoading;
  final String? errorMessage;

  const PlaybackSessionState({
    this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasActiveSession => session != null && session!.isActive && session!.playbackState != PlaybackLifecycleState.sessionEnded;
  bool get isPlaying => session?.playbackState == PlaybackLifecycleState.playing;

  PlaybackSessionState copyWith({
    PlaybackSessionEntity? session,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlaybackSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PlaybackSessionNotifier extends StateNotifier<PlaybackSessionState> {
  final PlaybackRepository _repository;
  final WebSocketService _wsService;
  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _wsSub;
  DateTime? _lastCorrectionTime;
  String? _lastHandledEventType;
  int _lastHandledTimestamp = 0;

  PlaybackSessionNotifier(this._repository, this._wsService, this._ref)
      : super(const PlaybackSessionState()) {
    _loadCurrentSession();
    _initWsListener();
  }

  void _initWsListener() {
    _wsSub = _wsService.messageStream.listen((data) {
      _handleWsMessage(data);
    });
  }

  void _handleWsMessage(Map<String, dynamic> data) async {
    AppLogger.debug('[PlaybackSessionNotifier] WS event received: $data');
    final type = data['type'] as String?;
    final event = data['event'] as String? ?? data['payload']?['event'] as String?;
    final senderId = data['senderId'] as String? ?? data['sender_id'] as String?;
    final currentUserId = _ref.read(authNotifierProvider).user?.id;

    final eventType = type ?? event;
    if (eventType == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // Deduplicate rapid duplicate events for same eventType within 300ms
    if ((eventType == 'play' || eventType == 'session_started' || eventType == 'resume' || eventType == 'pause') &&
        eventType == _lastHandledEventType &&
        (nowMs - _lastHandledTimestamp) < 300) {
      debugPrint('[PlaybackSessionNotifier] Ignoring rapid duplicate WS event $eventType within 300ms');
      return;
    }

    _lastHandledEventType = eventType;
    _lastHandledTimestamp = nowMs;

    final isLoopback = (senderId != null && currentUserId != null && senderId == currentUserId);
    debugPrint('[DIAGNOSTIC-3A] WS event parsed -> eventType: $eventType, senderId: $senderId, currentUserId: $currentUserId, isLoopback: $isLoopback, data: $data');

    if (isLoopback && (eventType == 'play' || eventType == 'resume' || eventType == 'pause')) {
      debugPrint('[PlaybackSessionNotifier] Ignoring loopback $eventType event for local state update and audio execution.');
      return;
    }

    final hasRoom = _ref.read(roomNotifierProvider).room != null;
    if (!state.hasActiveSession &&
        !hasRoom &&
        eventType != 'session_started' &&
        eventType != 'session_start') {
      debugPrint('[PlaybackSessionNotifier] No active room session. Ignoring WS audio sync event $eventType.');
      return;
    }

    if (eventType == 'session_started' || eventType == 'session_start') {
      final model = PlaybackSessionModel.fromJson(data);
      final targetSongId = model.currentSongId.isNotEmpty ? model.currentSongId : 'song_1';
      state = state.copyWith(session: model, isLoading: false);
      if (!isLoopback) {
        debugPrint('[PlaybackSessionNotifier] Remote session_started -> Starting playback and opening player for track $targetSongId');
        _ref.read(playerNotifierProvider.notifier).playSongById(targetSongId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            SafeNavigation.safeGo(context, '/player');
          }
        });
      }
      return;
    } else if (eventType == 'play' || eventType == 'resume') {
      final songId = data['currentSongId'] as String? ?? data['songId'] as String? ?? data['song_id'] as String?;
      final posMs = (data['positionMs'] as num? ?? data['position_ms'] as num? ?? 0).toInt();
      final activePlayerSongId = _ref.read(playerNotifierProvider).currentSong?.id;
      final targetSongId = (songId != null && songId.isNotEmpty)
          ? songId
          : ((state.session?.currentSongId.isNotEmpty == true) ? state.session!.currentSongId : activePlayerSongId) ?? 'song_1';

      final sessionModel = state.session ?? PlaybackSessionModel(
        id: data['sessionId'] as String? ?? 'session_default',
        roomId: data['roomId'] as String? ?? 'room_default',
        hostUserId: data['hostId'] as String? ?? (senderId ?? ''),
        currentSongId: targetSongId,
        playbackState: PlaybackLifecycleState.playing,
        positionMs: posMs,
      );

      final updated = sessionModel.copyWith(
        playbackState: PlaybackLifecycleState.playing,
        positionMs: posMs,
        currentSongId: targetSongId,
      );
      state = state.copyWith(session: updated, isLoading: false);
      _ref.read(sharedQueueNotifierProvider.notifier).setCurrentIndexForSongId(targetSongId);

      final currentSong = _ref.read(playerNotifierProvider).currentSong;
      if (currentSong != null) {
        _ref.read(mediaNotificationServiceProvider).showPlaybackNotification(
          currentSong,
          true,
          position: Duration(milliseconds: posMs),
        );
      }

      if (!isLoopback) {
        final playerState = _ref.read(playerNotifierProvider);
        final isAlreadyPlayingTarget = playerState.playbackState.isPlaying && playerState.currentSong?.id == targetSongId;
        if (isAlreadyPlayingTarget) {
          debugPrint('[PlaybackSessionNotifier] Local player is ALREADY playing $targetSongId. Skipping duplicate play execution.');
        } else {
          final playerNotifier = _ref.read(playerNotifierProvider.notifier);
          SoulSyncAudioHandler.instance.isRemoteSyncing = true;
          debugPrint('[DIAGNOSTIC-3C] Remote PLAY event received -> targetSongId: $targetSongId, posMs: $posMs');
          try {
            await playerNotifier.playSongById(targetSongId, initialPositionMs: posMs);
          } finally {
            Future.delayed(const Duration(milliseconds: 600), () {
              SoulSyncAudioHandler.instance.isRemoteSyncing = false;
            });
          }
        }
      } else {
        debugPrint('[DIAGNOSTIC-3C] Loopback PLAY event ignored for local audio execution.');
      }
    } else if (eventType == 'pause') {
      final posMs = (data['positionMs'] as num? ?? data['position_ms'] as num? ?? 0).toInt();
      if (state.session != null) {
        final updated = state.session!.copyWith(
          playbackState: PlaybackLifecycleState.paused,
          positionMs: posMs,
        );
        state = state.copyWith(session: updated);
      }

      final currentSong = _ref.read(playerNotifierProvider).currentSong;
      if (currentSong != null) {
        _ref.read(mediaNotificationServiceProvider).showPlaybackNotification(
          currentSong,
          false,
          position: Duration(milliseconds: posMs),
        );
      }

      if (!isLoopback) {
        debugPrint('[DIAGNOSTIC-3C] Remote PAUSE event received -> Invoking playerNotifier.pauseSong()');
        SoulSyncAudioHandler.instance.isRemoteSyncing = true;
        try {
          await _ref.read(playerNotifierProvider.notifier).pauseSong();
        } finally {
          Future.delayed(const Duration(milliseconds: 600), () {
            SoulSyncAudioHandler.instance.isRemoteSyncing = false;
          });
        }
      } else {
        debugPrint('[DIAGNOSTIC-3C] Loopback PAUSE event ignored for local audio execution.');
      }
    } else if (eventType == 'seek_changed') {
      final songId = data['song_id'] as String? ?? data['songId'] as String?;
      final posMs = (data['position_ms'] as num? ?? data['positionMs'] as num? ?? 0).toInt();
      if (state.session != null) {
        state = state.copyWith(
          session: state.session!.copyWith(
            positionMs: posMs,
            currentSongId: songId ?? state.session?.currentSongId,
          ),
        );
      }
      if (!isLoopback) {
        final playerNotifier = _ref.read(playerNotifierProvider.notifier);
        debugPrint('[PlaybackSessionNotifier] WS seek_changed event received. Seeking partner to $posMs ms');
        playerNotifier.seekLocal(Duration(milliseconds: posMs));
      }
    } else if (eventType == 'playback_state' || eventType == 'heartbeat') {
      final hostPosMs = (data['position_ms'] as num? ?? data['positionMs'] as num? ?? 0).toInt();
      final songId = data['song_id'] as String? ?? data['songId'] as String?;
      final packetTs = (data['timestamp'] as num? ?? 0).toInt();
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final transitDelayMs = (packetTs > 0 && nowMs > packetTs) ? (nowMs - packetTs).clamp(0, 1000) : 0;
      final estimatedHostPosMs = hostPosMs + transitDelayMs;

      if (state.session != null) {
        state = state.copyWith(
          session: state.session!.copyWith(
            positionMs: estimatedHostPosMs,
            currentSongId: songId ?? state.session?.currentSongId,
          ),
        );
      }
      if (!isLoopback) {
        final playerState = _ref.read(playerNotifierProvider);
        final clientPosMs = playerState.playbackState.position.inMilliseconds;
        final driftMs = (estimatedHostPosMs - clientPosMs).abs();
        final now = DateTime.now();
        final canCorrect = _lastCorrectionTime == null ||
            now.difference(_lastCorrectionTime!) > const Duration(seconds: 15);

        if (driftMs > 2000 && canCorrect) {
          _lastCorrectionTime = now;
          debugPrint(
              '[PlaybackSessionNotifier] Real drift detected ($driftMs ms > 2000ms). Performing rate-limited seek correction to $estimatedHostPosMs ms');
          _ref
              .read(playerNotifierProvider.notifier)
              .seekLocal(Duration(milliseconds: estimatedHostPosMs));
        }
      }
    } else if (eventType == 'sync_request') {
      if (!isLoopback) {
        final playerState = _ref.read(playerNotifierProvider);
        final currentSongId = playerState.currentSong?.id ?? 'song_1';
        final posMs = playerState.playbackState.position.inMilliseconds;
        final isPlaying = playerState.playbackState.isPlaying;

        debugPrint(
            '[PlaybackSessionNotifier] Host received sync_request. Replying with sync_response (song: $currentSongId, pos: $posMs ms, isPlaying: $isPlaying)');
        _wsService.send({
          'type': 'sync_response',
          'event': 'sync_response',
          'songId': currentSongId,
          'positionMs': posMs,
          'isPlaying': isPlaying,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } else if (eventType == 'sync_response') {
      if (!isLoopback) {
        final songId = data['songId'] as String? ?? 'song_1';
        final posMs = (data['positionMs'] as num? ?? 0).toInt();
        final isPlaying = data['isPlaying'] as bool? ?? false;

        debugPrint(
            '[PlaybackSessionNotifier] Partner received sync_response from host (song: $songId, pos: $posMs ms, isPlaying: $isPlaying)');
        final playerNotifier = _ref.read(playerNotifierProvider.notifier);
        if (isPlaying) {
          await playerNotifier.playSongById(songId, initialPositionMs: posMs);
        } else {
          await playerNotifier.seekLocal(Duration(milliseconds: posMs));
          await playerNotifier.pauseSong();
        }
      }
    } else if (eventType == 'playback_settings') {
      final isShuffle = data['isShuffle'] as bool?;
      final repeatStr = data['repeatMode'] as String?;
      final settingsNotifier = _ref.read(playbackSettingsNotifierProvider.notifier);
      if (isShuffle != null) {
        settingsNotifier.setShuffleFromRemote(isShuffle);
      }
      if (repeatStr != null) {
        final mode = LoopMode.values.firstWhere(
          (e) => e.name == repeatStr,
          orElse: () => LoopMode.off,
        );
        settingsNotifier.setRepeatFromRemote(mode);
      }
    } else if (eventType == 'session_ended' || eventType == 'session_end') {
      _ref.read(playerNotifierProvider.notifier).pauseSong();
      state = const PlaybackSessionState();
    }
  }

  Future<void> _loadCurrentSession() async {
    state = state.copyWith(isLoading: true);
    final roomState = _ref.read(roomNotifierProvider);
    final room = roomState.room;
    if (room == null) {
      debugPrint('[PlaybackSessionNotifier] No active room exists. Clearing session state.');
      state = const PlaybackSessionState(isLoading: false);
      return;
    }

    final authUser = _ref.read(authNotifierProvider).user;
    final defaultSession = PlaybackSessionEntity(
      id: 'session_${room.id}',
      roomId: room.id,
      hostUserId: room.hostUserId,
      hostName: authUser?.displayName ?? 'Host',
      playbackState: PlaybackLifecycleState.ready,
      isActive: true,
    );

    final result = await _repository.getCurrentSession();
    if (result.failure == null && result.session != null) {
      state = state.copyWith(session: result.session, isLoading: false);
      final sess = result.session!;
      if (sess.isActive && sess.playbackState == PlaybackLifecycleState.playing) {
        final playerNotifier = _ref.read(playerNotifierProvider.notifier);
        final songId = sess.currentSongId.isNotEmpty ? sess.currentSongId : 'song_1';
        debugPrint('[PlaybackSessionNotifier] Mid-song restoration on session load for track: $songId at ${sess.positionMs}ms');
        await playerNotifier.playSongById(songId);
        if (sess.positionMs > 1000) {
          await playerNotifier.seekTo(Duration(milliseconds: sess.positionMs));
        }
      }
    } else {
      state = state.copyWith(session: defaultSession, isLoading: false);
    }
  }

  void clearSessionState() {
    debugPrint('[PlaybackSessionNotifier] Clearing session state completely.');
    _ref.read(playerNotifierProvider.notifier).pauseSong();
    state = const PlaybackSessionState();
  }

  Future<bool> startSession(String roomId) async {
    state = const PlaybackSessionState(isLoading: true);
    final authUser = _ref.read(authNotifierProvider).user;
    final result = await _repository.startSession(roomId);
    if (result.failure != null) {
      state = state.copyWith(isLoading: false, errorMessage: result.failure!.message);
      return false;
    }

    final newSession = result.session ?? PlaybackSessionEntity(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      hostUserId: authUser?.id ?? 'user_host_1',
      hostName: authUser?.displayName ?? 'Host',
      playbackState: PlaybackLifecycleState.ready,
      isActive: true,
    );

    final targetSongId = newSession.currentSongId.isNotEmpty ? newSession.currentSongId : 'song_1';
    state = state.copyWith(session: newSession, isLoading: false);
    _ref.read(playerNotifierProvider.notifier).playSongById(targetSongId);

    _wsService.send({
      'type': 'session_started',
      'event': 'session_started',
      'sessionId': newSession.id,
      'roomId': roomId,
      'hostId': newSession.hostUserId,
      'senderId': authUser?.id ?? 'user_host_1',
      'currentSongId': targetSongId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return true;
  }

  int _lastPlayPauseTimeMs = 0;

  Future<bool> play({int positionMs = 0, String? songId}) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastPlayPauseTimeMs < 150) {
      debugPrint('[PlaybackSessionNotifier] Debouncing rapid play request (${nowMs - _lastPlayPauseTimeMs}ms < 150ms)');
      return false;
    }
    _lastPlayPauseTimeMs = nowMs;

    final currentUserId = _ref.read(authNotifierProvider).user?.id;
    if (state.session != null && !state.session!.canControl(currentUserId)) {
      state = state.copyWith(errorMessage: 'Playback is controlled exclusively by the Room Host.');
      return false;
    }

    final activePlayerSongId = _ref.read(playerNotifierProvider).currentSong?.id;
    final targetSongId = songId ?? ((state.session?.currentSongId.isNotEmpty == true) ? state.session!.currentSongId : activePlayerSongId) ?? 'song_1';

    // 1. Dispatch WS event immediately to partner (0ms latency) if session is active
    if (state.hasActiveSession) {
      _wsService.send({
        'type': 'play',
        'event': 'play',
        'sessionId': state.session?.id ?? 'session_default',
        'positionMs': positionMs,
        'songId': targetSongId,
        'senderId': currentUserId ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    // 2. Update local session state to PLAYING immediately
    if (state.session != null) {
      state = state.copyWith(
        session: state.session!.copyWith(
          playbackState: PlaybackLifecycleState.playing,
          positionMs: positionMs,
          currentSongId: targetSongId,
        ),
      );
    }

    // 3. Trigger local audio engine playback
    final playerNotifier = _ref.read(playerNotifierProvider.notifier);
    await playerNotifier.playSongById(targetSongId, initialPositionMs: positionMs);
    return true;
  }

  Future<bool> pause({int positionMs = 0}) async {
    final currentUserId = _ref.read(authNotifierProvider).user?.id;
    if (state.session != null && !state.session!.canControl(currentUserId)) {
      state = state.copyWith(errorMessage: 'Playback is controlled exclusively by the Room Host.');
      return false;
    }

    // 1. Dispatch WS event immediately to partner (0ms latency) if session is active
    if (state.hasActiveSession) {
      _wsService.send({
        'type': 'pause',
        'event': 'pause',
        'sessionId': state.session?.id ?? 'session_default',
        'positionMs': positionMs,
        'senderId': currentUserId ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    // 2. Update local session state to PAUSED immediately
    if (state.session != null) {
      state = state.copyWith(
        session: state.session!.copyWith(
          playbackState: PlaybackLifecycleState.paused,
          positionMs: positionMs,
        ),
      );
    }

    // 3. Pause local audio engine
    await _ref.read(playerNotifierProvider.notifier).pauseSong();
    return true;
  }

  Future<bool> resume({int positionMs = 0}) async {
    return play(positionMs: positionMs);
  }

  Future<bool> seek({int positionMs = 0, String? songId}) async {
    final currentUserId = _ref.read(authNotifierProvider).user?.id;
    final targetSongId = songId ?? state.session?.currentSongId ?? 'song_1';
    _ref.read(playerNotifierProvider.notifier).seekLocal(Duration(milliseconds: positionMs));

    if (state.session != null) {
      state = state.copyWith(
        session: state.session!.copyWith(positionMs: positionMs, currentSongId: targetSongId),
      );
    }

    if (state.hasActiveSession) {
      _wsService.send({
        'type': 'seek_changed',
        'event': 'seek_changed',
        'sessionId': state.session?.id ?? 'session_default',
        'song_id': targetSongId,
        'position_ms': positionMs,
        'senderId': currentUserId ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    return true;
  }

  Future<bool> endSession() async {
    final currentUserId = _ref.read(authNotifierProvider).user?.id;
    if (state.session != null && !state.session!.canControl(currentUserId)) {
      state = state.copyWith(errorMessage: 'Only the Room Host can end the listening session.');
      return false;
    }

    state = state.copyWith(isLoading: true);
    await _repository.endSession();
    _ref.read(playerNotifierProvider.notifier).pauseSong();

    _wsService.send({
      'type': 'session_ended',
      'event': 'session_ended',
      'sessionId': state.session?.id ?? 'session_default',
      'senderId': currentUserId ?? '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    state = const PlaybackSessionState();
    return true;
  }

  Future<void> refreshActiveSession() async {
    try {
      final res = await _repository.getCurrentSession();
      if (res.session != null) {
        final model = PlaybackSessionModel.fromEntity(res.session!);
        state = state.copyWith(session: model, isLoading: false);
      }
    } catch (e) {
      debugPrint('[PlaybackSessionNotifier] Refresh active session warning: $e');
    }
  }

  void broadcastHostSnapshot({
    required String currentSongId,
    required int positionMs,
    required bool isPlaying,
  }) {
    _wsService.send({
      'type': 'playback_state',
      'event': 'playback_snapshot',
      'songId': currentSongId,
      'positionMs': positionMs,
      'isPlaying': isPlaying,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void requestSyncFromHost() {
    _wsService.send({
      'type': 'sync_request',
      'event': 'sync_request',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }
}

final playbackRepositoryProvider = Provider<PlaybackRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PlaybackApiRepositoryImpl(dioClient);
});

final playbackSessionNotifierProvider =
    StateNotifierProvider<PlaybackSessionNotifier, PlaybackSessionState>((ref) {
  final repo = ref.watch(playbackRepositoryProvider);
  final ws = ref.watch(webSocketServiceProvider);
  final notifier = PlaybackSessionNotifier(repo, ws, ref);

  ref.listen(roomNotifierProvider, (previous, next) {
    if (next.room != null) {
      notifier._loadCurrentSession();
    } else if (previous?.room != null && next.room == null) {
      notifier.clearSessionState();
    }
  });

  return notifier;
});
