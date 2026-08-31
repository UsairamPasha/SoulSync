import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';
import 'package:soulsync/features/realtime/services/web_socket_service.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

class RealtimeStatusCard extends ConsumerWidget {
  const RealtimeStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(webSocketServiceProvider);
    final presence = ref.watch(partnerPresenceNotifierProvider);

    final status = ws.status;
    final quality = ws.quality;
    final latency = presence.latencyMs;

    String statusText;
    Color color;

    switch (status) {
      case RealtimeConnectionStatus.connected:
        statusText = 'WebSocket Connected';
        color = AppColors.success;
        break;
      case RealtimeConnectionStatus.connecting:
      case RealtimeConnectionStatus.reconnecting:
        statusText = 'Reconnecting...';
        color = AppColors.warning;
        break;
      default:
        statusText = 'Disconnected';
        color = AppColors.error;
        break;
    }

    return AppBaseCard(
      margin: EdgeInsets.zero,
      padding: AppSpacing.paddingMD,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors_rounded, color: color, size: 20),
              AppSpacing.hGapSM,
              Text(
                statusText,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${latency}ms',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppSpacing.vGapXS,
          Text(
            'Connection Quality: ${quality.name.toUpperCase()} • Partner: ${presence.isOnline ? "ONLINE" : "OFFLINE"}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
