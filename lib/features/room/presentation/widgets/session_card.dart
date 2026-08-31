import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/room/domain/entities/listening_session_entity.dart';
import 'package:soulsync/features/room/presentation/widgets/sync_badge.dart';

class SessionCard extends ConsumerWidget {
  final ListeningSessionEntity session;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onPlayPause,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = session.currentSong;

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLG),
      child: InkWell(
        onTap: onTap ?? () => SafeNavigation.safeGo(context, '/player'),
        borderRadius: AppRadius.borderLG,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wifi_tethering_rounded,
                          size: 18, color: AppColors.primary),
                      AppSpacing.hGapXS,
                      Text(
                        'Live Synchronized Session',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SyncBadge(),
                ],
              ),
              AppSpacing.vGapMD,
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderMD,
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  AppSpacing.hGapMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song?.title ?? 'No Track Playing',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song?.artist ?? 'Select a song to start listening together',
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
                      session.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                    onPressed: onPlayPause ?? () {
                      final sessionNotifier = ref.read(playbackSessionNotifierProvider.notifier);
                      final playerState = ref.read(playerNotifierProvider);
                      final posMs = playerState.playbackState.position.inMilliseconds;
                      if (session.isPlaying) {
                        sessionNotifier.pause(positionMs: posMs);
                      } else {
                        final targetSongId = session.currentSong?.id ?? 'song_1';
                        sessionNotifier.play(songId: targetSongId, positionMs: posMs);
                      }
                    },
                  ),
                ],
              ),
              AppSpacing.vGapSM,
              LinearProgressIndicator(
                value: (session.duration.inSeconds > 0)
                    ? (session.position.inSeconds / session.duration.inSeconds)
                        .clamp(0.0, 1.0)
                    : 0.0,
                color: AppColors.primary,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
              ),
              AppSpacing.vGapXXS,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(session.position),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatDuration(session.duration),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
