import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/home/data/models/dashboard_data_model.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

class RecentActivitySection extends StatelessWidget {
  final List<ActivityItemModel> activities;

  const RecentActivitySection({
    super.key,
    required this.activities,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'song':
        return Icons.music_note_rounded;
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'playlist':
        return Icons.queue_music_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'song':
        return AppColors.primary;
      case 'chat':
        return AppColors.success;
      case 'playlist':
        return AppColors.secondary;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Couple Activity',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vGapSM,
        if (activities.isEmpty)
          AppBaseCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_outline_rounded,
                      size: 20, color: AppColors.primary),
                ),
                AppSpacing.hGapMD,
                Expanded(
                  child: Text(
                    'No recent activity yet. Start listening together to create your first memory.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...activities.map(
            (act) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AppBaseCard(
                margin: EdgeInsets.zero,
                padding: AppSpacing.paddingMD,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getColor(act.type).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIcon(act.type),
                          size: 18, color: _getColor(act.type)),
                    ),
                    AppSpacing.hGapMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act.title,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            act.subtitle,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      act.timeAgo,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
