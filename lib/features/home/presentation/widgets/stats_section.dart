import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/home/data/models/dashboard_data_model.dart';

class StatsSection extends StatelessWidget {
  final UserStatsModel stats;

  const StatsSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Listening Statistics',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vGapSM,
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Tracks Played',
                value: '${stats.totalSongs}',
                icon: Icons.music_note_rounded,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.hGapSM,
            Expanded(
              child: _StatCard(
                label: 'Shared Playlists',
                value: '${stats.totalPlaylists}',
                icon: Icons.queue_music_rounded,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        AppSpacing.vGapSM,
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Favorites',
                value: '${stats.totalFavorites}',
                icon: Icons.favorite_rounded,
                color: AppColors.accent,
              ),
            ),
            AppSpacing.hGapSM,
            Expanded(
              child: _StatCard(
                label: 'Listening Hours',
                value: '${stats.listeningHours} hrs',
                icon: Icons.timelapse_rounded,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: context.customColors.cardBackground,
        borderRadius: AppRadius.borderMD,
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          AppSpacing.hGapSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
