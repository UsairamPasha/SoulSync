import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/providers/recently_played_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/song_tile.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';

import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';

class RecentlyPlayedScreen extends ConsumerWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(recentlyPlayedNotifierProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Recently Played History'),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? const AppEmptyState(
                title: 'No History Yet',
                description:
                    'Tracks you listen to will automatically be saved here with play counts.',
                icon: Icons.history_toggle_off_rounded,
              )
            : ListView.builder(
                padding: AppSpacing.paddingLG,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Column(
                    children: [
                      SongTile(
                        song: item.song,
                        onTap: () {
                          final sessionState = ref.read(playbackSessionNotifierProvider);
                          if (sessionState.hasActiveSession) {
                            ref.read(playbackSessionNotifierProvider.notifier).play(songId: item.song.id, positionMs: 0);
                          } else {
                            ref.read(playerNotifierProvider.notifier).playSong(item.song);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 64, bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.playCount} plays',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
