import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/shared/models/track_model.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

/// Reusable Music Track Card component for SoulSync streaming lists.
class AppMusicCard extends StatelessWidget {
  final TrackModel track;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool isPlaying;
  final bool isFavorite;

  const AppMusicCard({
    super.key,
    required this.track,
    this.onTap,
    this.onMoreTap,
    this.isPlaying = false,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      hasGlow: isPlaying,
      child: Row(
        children: [
          // Album Artwork Placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: AppRadius.borderMD,
            ),
            child: Icon(
              isPlaying ? Icons.equalizer_rounded : Icons.music_note_rounded,
              color: isPlaying
                  ? context.colorScheme.primary
                  : context.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          AppSpacing.hGapMD,
          // Track Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: isPlaying
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vGapXXS,
                Text(
                  '${track.artist} • ${track.album}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isFavorite) ...[
            Icon(Icons.favorite_rounded,
                color: context.colorScheme.tertiary, size: 20),
            AppSpacing.hGapSM,
          ],
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: onMoreTap,
          ),
        ],
      ),
    );
  }
}
