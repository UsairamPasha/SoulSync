import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';
import 'package:soulsync/features/notifications/presentation/providers/notification_providers.dart';
import 'package:soulsync/features/realtime/presentation/widgets/sync_badge.dart';

class DashboardHeader extends ConsumerWidget {
  final String userName;
  final String? avatarUrl;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationNotifierProvider);
    final unreadCount = notifState.unreadCount;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: context.colorScheme.primaryContainer,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AppSpacing.hGapMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      userName,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.hGapSM,
                  const SyncBadge(),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: unreadCount > 0
              ? Badge(
                  label: Text('$unreadCount'),
                  backgroundColor: context.colorScheme.error,
                  child: const Icon(Icons.notifications_none_rounded),
                )
              : const Icon(Icons.notifications_none_rounded),
          onPressed: () {
            SafeNavigation.safePush(context, '/notifications');
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => SafeNavigation.safePush(context, '/settings'),
        ),
      ],
    );
  }
}
