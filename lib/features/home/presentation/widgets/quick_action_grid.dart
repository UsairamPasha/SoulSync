import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      const _QuickActionItem(
        title: 'Play Music',
        icon: Icons.play_arrow_rounded,
        color: AppColors.primary,
        route: '/player',
      ),
      const _QuickActionItem(
        title: 'Playlists',
        icon: Icons.queue_music_rounded,
        color: AppColors.secondary,
        route: '/playlist',
      ),
      const _QuickActionItem(
        title: 'Favorites',
        icon: Icons.favorite_rounded,
        color: AppColors.accent,
        route: '/favorites',
      ),
      const _QuickActionItem(
        title: 'Couple Chat',
        icon: Icons.chat_bubble_rounded,
        color: AppColors.success,
        route: '/chat',
      ),
      const _QuickActionItem(
        title: 'Sync Room',
        icon: Icons.graphic_eq_rounded,
        color: AppColors.warning,
        route: '/room',
      ),
      _QuickActionItem(
        title: 'Settings',
        icon: Icons.settings_rounded,
        color: context.colorScheme.outline,
        route: '/settings',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return InkWell(
          onTap: () => SafeNavigation.safePush(context, item.route),
          borderRadius: AppRadius.borderMD,
          child: Container(
            decoration: BoxDecoration(
              color: context.customColors.cardBackground,
              borderRadius: AppRadius.borderMD,
              border: Border.all(
                color:
                    context.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 22, color: item.color),
                ),
                AppSpacing.vGapXS,
                Text(
                  item.title,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
