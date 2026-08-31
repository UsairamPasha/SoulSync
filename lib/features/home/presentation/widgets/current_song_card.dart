import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

import 'package:soulsync/core/navigation/safe_navigation.dart';

class CurrentSongCard extends ConsumerWidget {
  const CurrentSongCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;
    final sessionState = ref.watch(playbackSessionNotifierProvider);
    final isEnginePlaying = ref.watch(playerNotifierProvider.notifier).isAudioEnginePlaying;
    final isPlaying = (sessionState.hasActiveSession && sessionState.session != null)
        ? ((sessionState.session?.isPlaying ?? false) || isEnginePlaying)
        : (playerState.playbackState.isPlaying || isEnginePlaying);
    final position = playerState.playbackState.position;
    final duration = playerState.playbackState.duration;

    final progress = (duration.inMilliseconds > 0)
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return AppBaseCard(
      margin: EdgeInsets.zero,
      padding: AppSpacing.paddingMD,
      onTap: () => SafeNavigation.safeGo(context, '/player'),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: AppRadius.borderMD,
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  size: 28,
                  color: context.colorScheme.primary,
                ),
              ),
              AppSpacing.hGapMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong?.title ?? 'No Active Playback',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGapXXS,
                    Text(
                      currentSong?.artist ?? 'Select a track from playlist',
                      style: context.textTheme.bodySmall?.copyWith(
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
                  playerState.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: playerState.isFavorite
                      ? AppColors.accent
                      : context.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  ref.read(playerNotifierProvider.notifier).toggleFavorite();
                },
              ),
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 38,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  if (sessionState.hasActiveSession) {
                    final sessionNotifier = ref.read(playbackSessionNotifierProvider.notifier);
                    final posMs = playerState.playbackState.position.inMilliseconds;
                    if (isPlaying) {
                      sessionNotifier.pause(positionMs: posMs);
                    } else {
                      final targetSongId = currentSong?.id ?? 'song_1';
                      sessionNotifier.play(songId: targetSongId, positionMs: posMs);
                    }
                  } else {
                    ref.read(playerNotifierProvider.notifier).togglePlayPause();
                  }
                },
              ),
            ],
          ),
          AppSpacing.vGapSM,
          ClipRRect(
            borderRadius: AppRadius.borderFull,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  context.colorScheme.outlineVariant.withValues(alpha: 0.3),
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
