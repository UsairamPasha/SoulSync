import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/queue/presentation/providers/queue_provider.dart';

class QueueDiagnosticsOverlay extends ConsumerWidget {
  const QueueDiagnosticsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(sharedQueueNotifierProvider);
    final sessionState = ref.watch(playbackSessionNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).user;
    final theme = Theme.of(context);

    final queue = queueState.queue;
    final isHost = sessionState.session?.isHost(authUser?.id) ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 18,
                color: isHost ? AppColors.primary : AppColors.accent,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shared Queue Sync: ${queueState.lifecycleState.name.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Tracks: ${queue?.length ?? 0} | Index: ${queue?.currentIndex ?? 0} | ${isHost ? "Host Authority" : "Partner Connected"}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded, size: 18, color: AppColors.primary),
            tooltip: 'Sync Queue Snapshot',
            onPressed: () => ref.read(sharedQueueNotifierProvider.notifier).recoverQueue(),
          ),
        ],
      ),
    );
  }
}
