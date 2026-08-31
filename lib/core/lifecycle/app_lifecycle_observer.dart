import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/logger/app_logger.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';

enum SoulSyncAppLifecycleState {
  resumed,
  inactive,
  paused,
  detached,
  hidden,
}

class AppLifecycleObserver extends StateNotifier<SoulSyncAppLifecycleState>
    with WidgetsBindingObserver {
  final Ref _ref;

  AppLifecycleObserver(this._ref) : super(SoulSyncAppLifecycleState.resumed) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.info('[AppLifecycleObserver] Lifecycle state changed: ${state.name}');

    switch (state) {
      case AppLifecycleState.resumed:
        this.state = SoulSyncAppLifecycleState.resumed;
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
        this.state = SoulSyncAppLifecycleState.inactive;
        break;
      case AppLifecycleState.paused:
        this.state = SoulSyncAppLifecycleState.paused;
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        this.state = SoulSyncAppLifecycleState.detached;
        break;
      case AppLifecycleState.hidden:
        this.state = SoulSyncAppLifecycleState.hidden;
        break;
    }
  }

  void _handleAppPaused() {
    AppLogger.debug('[AppLifecycleObserver] App paused - maintaining audio session');
  }

  Future<void> _handleAppResumed() async {
    AppLogger.info('[AppLifecycleObserver] App resumed. Triggering full resynchronization sequence...');

    final wsService = _ref.read(webSocketServiceProvider);
    await wsService.reconnectIfNeeded();

    // Give connection 300ms to establish if reconnecting
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Refresh Room state and reassert presence
    final roomNotifier = _ref.read(roomNotifierProvider.notifier);
    await roomNotifier.refreshActiveRoom();

    // Refresh Playback Session state
    final sessionNotifier = _ref.read(playbackSessionNotifierProvider.notifier);
    await sessionNotifier.refreshActiveSession();

    // Request or broadcast sync snapshot
    final sessionState = _ref.read(playbackSessionNotifierProvider);
    final playerState = _ref.read(playerNotifierProvider);

    if (sessionState.session != null) {
      final authUser = _ref.read(authNotifierProvider).user;
      final isHost = sessionState.session!.isHost(authUser?.id);

      if (isHost) {
        AppLogger.info('[AppLifecycleObserver] Host resumed - broadcasting playback snapshot to partner');
        sessionNotifier.broadcastHostSnapshot(
          currentSongId: playerState.currentSong?.id ?? 'song_1',
          positionMs: playerState.playbackState.position.inMilliseconds,
          isPlaying: playerState.playbackState.isPlaying,
        );
      } else {
        AppLogger.info('[AppLifecycleObserver] Partner resumed - requesting playback sync from host');
        sessionNotifier.requestSyncFromHost();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

final appLifecycleObserverProvider =
    StateNotifierProvider<AppLifecycleObserver, SoulSyncAppLifecycleState>((ref) {
  return AppLifecycleObserver(ref);
});
