import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soulsync/features/chat/presentation/providers/chat_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/mini_player.dart';
import 'package:soulsync/shared/navigation/soulsync_bottom_nav_bar.dart';

/// Stateful Shell wrapper preserving state across bottom navigation tabs with persistent MiniPlayer.
class NavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  void _onTapTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadChatCount = ref.watch(chatNotifierProvider).unreadCount;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (navigationShell.currentIndex != 1) const MiniPlayer(),
          SoulSyncBottomNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTapTab,
            unreadChatCount: unreadChatCount,
          ),
        ],
      ),
    );
  }
}
