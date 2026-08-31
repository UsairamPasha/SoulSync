import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/presentation/providers/queue_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/queue_tile.dart';
import 'package:soulsync/shared/widgets/buttons/app_text_button.dart';

import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';

class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueNotifierProvider);
    final queueNotifier = ref.read(queueNotifierProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGapMD,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Playback Queue',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${queue.totalLength} tracks • ${_formatDuration(queue.totalDuration)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (queue.upcomingSongs.isNotEmpty)
                AppTextButton(
                  label: 'Clear Queue',
                  onPressed: () => queueNotifier.clearQueue(),
                ),
            ],
          ),
          const Divider(height: 24),
          if (queue.currentSong != null) ...[
            Text(
              'Now Playing',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            QueueTile(
              song: queue.currentSong!,
              isCurrent: true,
              onTap: () {},
              onRemove: () {},
            ),
            const Divider(height: 20),
          ],
          Text(
            'Upcoming Tracks (${queue.upcomingSongs.length})',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapSM,
          Expanded(
            child: queue.upcomingSongs.isEmpty
                ? AppEmptyState.emptyQueue()
                : ReorderableListView.builder(
                    itemCount: queue.upcomingSongs.length,
                    onReorderItem: (oldIdx, newIdx) {
                      queueNotifier.reorder(oldIdx, newIdx);
                    },
                    itemBuilder: (context, index) {
                      final song = queue.upcomingSongs[index];
                      return QueueTile(
                        key: ValueKey('queue_item_${song.id}_$index'),
                        song: song,
                        onTap: () {
                          final sessionState = ref.read(playbackSessionNotifierProvider);
                          if (sessionState.hasActiveSession) {
                            ref.read(playbackSessionNotifierProvider.notifier).play(songId: song.id, positionMs: 0);
                          } else {
                            queueNotifier.playSongFromQueue(index);
                          }
                        },
                        onRemove: () => queueNotifier.removeAt(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
