import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Material 3 Bottom Navigation Bar for SoulSync Application Shell.
class SoulSyncBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadChatCount;

  const SoulSyncBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadChatCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Container(
      decoration: BoxDecoration(
        color: customColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon:
                Icon(Icons.headphones_rounded, color: AppColors.primary),
            label: 'Player',
          ),
          const NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon:
                Icon(Icons.queue_music_rounded, color: AppColors.primary),
            label: 'Playlist',
          ),
          NavigationDestination(
            icon: unreadChatCount > 0
                ? Badge(
                    label: Text('$unreadChatCount'),
                    backgroundColor: AppColors.accent,
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  )
                : const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: unreadChatCount > 0
                ? Badge(
                    label: Text('$unreadChatCount'),
                    backgroundColor: AppColors.accent,
                    child: const Icon(Icons.chat_bubble_rounded,
                        color: AppColors.primary),
                  )
                : const Icon(Icons.chat_bubble_rounded,
                    color: AppColors.primary),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
