import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/music_artwork.dart';

/// Persistent Mini Player widget anchored above bottom navigation bar.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

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

    final songIdInt = int.tryParse(currentSong.id);

    return Container(
      decoration: BoxDecoration(
        color: context.customColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live progress indicator
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.transparent,
            color: AppColors.primary,
            minHeight: 2.5,
          ),
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -8) {
                SafeNavigation.safeGo(context, '/player');
              }
            },
            onTap: () => SafeNavigation.safeGo(context, '/player'),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.borderSM,
                    child: MusicArtwork(
                      songId: songIdInt,
                      size: 44,
                    ),
                  ),
                  AppSpacing.hGapMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentSong.title,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentSong.artist,
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
                    icon: const Icon(Icons.skip_previous_rounded, size: 24),
                    onPressed: () {
                      ref
                          .read(playerNotifierProvider.notifier)
                          .skipToPrevious();
                    },
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
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (sessionState.hasActiveSession) {
                        final sessionNotifier = ref.read(playbackSessionNotifierProvider.notifier);
                        final posMs = playerState.playbackState.position.inMilliseconds;
                        if (isPlaying) {
                          sessionNotifier.pause(positionMs: posMs);
                        } else {
                          final targetSongId = currentSong.id;
                          sessionNotifier.play(songId: targetSongId, positionMs: posMs);
                        }
                      } else {
                        ref.read(playerNotifierProvider.notifier).togglePlayPause();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 28),
                    onPressed: () {
                      ref.read(playerNotifierProvider.notifier).skipToNext();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
