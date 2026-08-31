import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/core/navigation/safe_navigation.dart';
import 'package:soulsync/features/notifications/domain/entities/notification_entity.dart';
import 'package:soulsync/features/notifications/presentation/providers/notification_providers.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.partnerJoined:
        return Icons.favorite_rounded;
      case NotificationType.sessionStarted:
        return Icons.graphic_eq_rounded;
      case NotificationType.relationshipInvite:
        return Icons.person_add_rounded;
      case NotificationType.chatMessage:
        return Icons.chat_bubble_rounded;
      case NotificationType.systemAlert:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.partnerJoined:
        return AppColors.accent;
      case NotificationType.sessionStarted:
        return AppColors.primary;
      case NotificationType.relationshipInvite:
        return AppColors.secondary;
      case NotificationType.chatMessage:
        return AppColors.success;
      case NotificationType.systemAlert:
        return AppColors.warning;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);
    final notifications = state.notifications;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notifier.markAllAsRead(),
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const Center(
                child: AppEmptyState(
                  title: 'No Notifications',
                  description:
                      'You are all caught up! Updates from your partner will appear here.',
                  icon: Icons.notifications_none_rounded,
                ),
              )
            : ListView.separated(
                padding: AppSpacing.paddingLG,
                itemCount: notifications.length,
                separatorBuilder: (context, index) => AppSpacing.vGapSM,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final icon = _getIconForType(notif.type);
                  final color = _getColorForType(notif.type);

                  return Dismissible(
                    key: Key(notif.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => notifier.clearNotification(notif.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        borderRadius: AppRadius.borderMD,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error),
                    ),
                    child: AppBaseCard(
                      padding: AppSpacing.paddingMD,
                      backgroundColor: notif.isRead
                          ? context.customColors.cardBackground
                          : AppColors.primary.withValues(alpha: 0.08),
                      child: InkWell(
                        onTap: () {
                          notifier.markAsRead(notif.id);
                          final route = notif.data?['targetRoute'] as String?;
                          if (route != null && route.isNotEmpty) {
                            SafeNavigation.safePush(context, route);
                          }
                        },
                        borderRadius: AppRadius.borderMD,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, size: 20, color: color),
                            ),
                            AppSpacing.hGapMD,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: context.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: notif.isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        _formatTime(notif.createdAt),
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                          color: context
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.vGapXXS,
                                  Text(
                                    notif.body,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: context
                                          .colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!notif.isRead) ...[
                              AppSpacing.hGapSM,
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
