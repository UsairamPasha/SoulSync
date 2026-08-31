import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';

class SyncBadge extends ConsumerWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);

    Color badgeColor;
    String label;
    IconData icon;

    switch (status) {
      case AppConnectionStatus.listeningTogether:
        badgeColor = AppColors.accent;
        label = 'Listening Together';
        icon = Icons.graphic_eq_rounded;
        break;
      case AppConnectionStatus.connected:
        badgeColor = AppColors.success;
        label = 'Connected';
        icon = Icons.wifi_rounded;
        break;
      case AppConnectionStatus.partnerOffline:
        badgeColor = Colors.orange;
        label = 'Partner Offline';
        icon = Icons.person_outline_rounded;
        break;
      case AppConnectionStatus.connecting:
        badgeColor = AppColors.warning;
        label = 'Connecting...';
        icon = Icons.sync_rounded;
        break;
      case AppConnectionStatus.reconnecting:
        badgeColor = AppColors.warning;
        label = 'Reconnecting...';
        icon = Icons.sync_problem_rounded;
        break;
      case AppConnectionStatus.disconnected:
        badgeColor = AppColors.error;
        label = 'Disconnected';
        icon = Icons.wifi_off_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          AppSpacing.hGapXS,
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
