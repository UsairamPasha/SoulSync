import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/playback_settings_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/animated_cover_art.dart';
import 'package:soulsync/features/player/presentation/widgets/playback_speed_dialog.dart';
import 'package:soulsync/features/playback/presentation/widgets/sync_diagnostics_overlay.dart';
import 'package:soulsync/features/player/presentation/widgets/song_search_sheet.dart';
import 'package:soulsync/features/player/presentation/widgets/sleep_timer_dialog.dart';
import 'package:soulsync/features/player/presentation/widgets/volume_slider.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

import 'package:soulsync/features/queue/presentation/screens/queue_screen.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const QueueScreen(),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const PlaybackSpeedDialog(),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SleepTimerDialog(),
    );
  }

  void _showSearchSongsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SongSearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final playerNotifier = ref.read(playerNotifierProvider.notifier);
    final playbackSettings = ref.watch(playbackSettingsNotifierProvider);
    final playbackSettingsNotifier =
        ref.read(playbackSettingsNotifierProvider.notifier);

    final sessionState = ref.watch(playbackSessionNotifierProvider);
    final sessionNotifier = ref.read(playbackSessionNotifierProvider.notifier);
    final presenceState = ref.watch(partnerPresenceNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).user;
    final roomState = ref.watch(roomNotifierProvider);

    final session = sessionState.session;
    final isHost = session?.isHost(authUser?.id) ?? true;

    final currentSong = playerState.currentSong;
    final playback = playerState.playbackState;

    final isPlaying = (sessionState.hasActiveSession && sessionState.session != null)
        ? ((sessionState.session?.isPlaying ?? false) || playerNotifier.isAudioEnginePlaying)
        : (playback.isPlaying || playerNotifier.isAudioEnginePlaying);
    final position = playback.position;
    final duration = playback.duration;
    final isFavorite = playerState.isFavorite;

    final maxDurationSec =
        duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 180.0;
    final currentPosSec =
        position.inSeconds.toDouble().clamp(0.0, maxDurationSec);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Synchronized Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchSongsSheet(context),
            tooltip: 'Search Songs',
          ),
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => _showSleepTimerDialog(context),
            tooltip: 'Sleep Timer',
          ),
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () => _showQueueSheet(context),
            tooltip: 'Playback Queue',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SyncDiagnosticsOverlay(),
              // Shared Listening Room Active Banner
              if (sessionState.hasActiveSession) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderMD,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_rounded, color: AppColors.primary, size: 20),
                      AppSpacing.hGapSM,
                      Expanded(
                        child: Text(
                          'Synchronized Listening Active',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGapMD,
              ],

              // Badges Row (Role, Presence Quality, Sync Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    avatar: Icon(
                      isHost ? Icons.star_rounded : Icons.favorite_rounded,
                      size: 14,
                      color: isHost ? AppColors.accent : AppColors.primary,
                    ),
                    label: Text(
                      isHost ? 'Host' : 'Partner',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  AppSpacing.hGapSM,
                  Chip(
                    avatar: Icon(
                      Icons.wifi_rounded,
                      size: 14,
                      color: presenceState.isOnline
                          ? AppColors.success
                          : context.colorScheme.outline,
                    ),
                    label: Text(
                      presenceState.isOnline ? 'Partner Online' : 'Partner Offline',
                      style: context.textTheme.labelSmall,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              AppSpacing.vGapMD,

              // Animated Rotating Album Cover with Crossfade Transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: AnimatedCoverArt(
                  key: ValueKey<String>(currentSong?.id ?? 'none'),
                  isPlaying: isPlaying,
                  songId: currentSong?.id,
                  size: 230,
                ),
              ),

              AppSpacing.vGapXL,

              // Track Title & Artist with Favorite Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong?.title ?? 'Soulmate Serenade',
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGapXXS,
                        Text(
                          '${currentSong?.artist ?? "SoulSync Artists"} • ${currentSong?.album ?? "Synchronized Suite"}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? AppColors.accent
                          : context.colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
                    onPressed: () async {
                      await playerNotifier.toggleFavorite();
                      if (context.mounted) {
                        AppSnackBars.showSuccess(
                          context,
                          !isFavorite
                              ? 'Added to Favorites'
                              : 'Removed from Favorites',
                        );
                      }
                    },
                  ),
                ],
              ),

              AppSpacing.vGapMD,

              // Seek Slider & Timers
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: context.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                      thumbColor: AppColors.primary,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: currentPosSec,
                      min: 0,
                      max: maxDurationSec,
                      onChanged: (val) {
                        final posMs = (val * 1000).toInt();
                        if (sessionState.hasActiveSession || roomState.room != null) {
                          sessionNotifier.seek(positionMs: posMs);
                        } else {
                          playerNotifier.seek(Duration(seconds: val.toInt()));
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpacing.vGapLG,

              // Playback Transport Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: (playbackSettings.isShuffle || playerState.playbackState.isShuffle)
                          ? AppColors.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await playbackSettingsNotifier.toggleShuffle();
                      await playerNotifier.toggleShuffle();
                    },
                    tooltip: 'Shuffle',
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, size: 36),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      playerNotifier.skipToPrevious();
                    },
                    tooltip: 'Previous Track',
                  ),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        key: ValueKey<bool>(isPlaying),
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (sessionState.hasActiveSession) {
                        if (isPlaying) {
                          sessionNotifier.pause(positionMs: position.inMilliseconds);
                        } else {
                          final targetSongId = currentSong?.id ?? session?.currentSongId ?? 'song_1';
                          sessionNotifier.play(
                            songId: targetSongId,
                            positionMs: position.inMilliseconds,
                          );
                        }
                      } else {
                        playerNotifier.togglePlayPause();
                      }
                    },
                    tooltip: isPlaying ? 'Pause' : 'Play',
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 36),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      playerNotifier.skipToNext();
                    },
                    tooltip: 'Next Track',
                  ),
                  IconButton(
                    icon: Icon(
                      playbackSettings.repeatMode == LoopMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      color: playbackSettings.repeatMode != LoopMode.off
                          ? AppColors.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => playbackSettingsNotifier.cycleRepeatMode(),
                    tooltip: 'Repeat Mode',
                  ),
                ],
              ),

              AppSpacing.vGapMD,

              // Secondary Controls Row (Speed, Volume, Equalizer, Lyrics)
              Row(
                children: [
                  // Playback Speed Button
                  ActionChip(
                    avatar: const Icon(Icons.speed_rounded, size: 16),
                    label: Text('${playbackSettings.speed}x'),
                    onPressed: () => _showSpeedDialog(context),
                  ),
                  AppSpacing.hGapSM,
                  // Equalizer Placeholder
                  IconButton(
                    icon: const Icon(Icons.equalizer_rounded, size: 20),
                    onPressed: () {
                      AppSnackBars.showInfo(
                          context, 'Equalizer preset active (Flat).');
                    },
                    tooltip: 'Equalizer',
                  ),
                  // Lyrics Placeholder
                  IconButton(
                    icon: const Icon(Icons.lyrics_outlined, size: 20),
                    onPressed: () {
                      AppSnackBars.showInfo(
                          context, 'Lyrics sync coming in next sprint.');
                    },
                    tooltip: 'Lyrics',
                  ),
                ],
              ),

              AppSpacing.vGapSM,

              // Interactive Volume Slider
              const VolumeSlider(),

              AppSpacing.vGapLG,
            ],
          ),
        ),
      ),
    );
  }
}
