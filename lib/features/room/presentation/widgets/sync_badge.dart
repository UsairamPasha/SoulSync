import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';

import 'package:soulsync/features/room/domain/entities/listening_session_entity.dart';

class SyncBadge extends StatelessWidget {
  final SyncQualityState state;

  const SyncBadge({super.key, this.state = SyncQualityState.synced});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;
    IconData icon;

    switch (state) {
      case SyncQualityState.synced:
        badgeColor = Colors.green;
        label = '100% Synced';
        icon = Icons.bolt_rounded;
        break;
      case SyncQualityState.syncing:
        badgeColor = AppColors.primary;
        label = 'Syncing...';
        icon = Icons.sync_rounded;
        break;
      case SyncQualityState.delayed:
        badgeColor = Colors.orange;
        label = 'Sync Lag (~50ms)';
        icon = Icons.network_check_rounded;
        break;
      case SyncQualityState.offline:
        badgeColor = Colors.red;
        label = 'Partner Offline';
        icon = Icons.wifi_off_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
