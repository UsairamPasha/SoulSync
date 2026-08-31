import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/song_search_sheet.dart';
import 'package:soulsync/features/queue/presentation/providers/queue_provider.dart';
import 'package:soulsync/features/queue/presentation/widgets/queue_diagnostics_overlay.dart';
import 'package:soulsync/features/queue/presentation/widgets/queue_tile.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  void _showAddSongsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SongSearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(sharedQueueNotifierProvider);
    final queueNotifier = ref.read(sharedQueueNotifierProvider.notifier);
    final sessionState = ref.watch(playbackSessionNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).user;

    final isHost = sessionState.session?.isHost(authUser?.id) ?? true;
    final playerState = ref.watch(playerNotifierProvider);
    final localQueue = playerState.queue;

    final queue = queueState.queue;
    final songs = (queue?.songs.isNotEmpty == true) ? queue!.songs : localQueue;

    final activeSongId = sessionState.session?.currentSongId ?? playerState.currentSong?.id;
    final effectiveIndex = (queue?.songs.isNotEmpty == true)
        ? (queue?.effectiveIndexForId(activeSongId) ?? 0)
        : playerState.currentIndex.clamp(0, songs.isEmpty ? 0 : songs.length - 1);

    final currentSong = (songs.isNotEmpty && effectiveIndex >= 0 && effectiveIndex < songs.length)
        ? songs[effectiveIndex]
        : playerState.currentSong;

    final upNext = (songs.isNotEmpty && effectiveIndex + 1 < songs.length)
        ? songs.sublist(effectiveIndex + 1)
        : <SongEntity>[];

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Shared Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            onPressed: () => _showAddSongsSheet(context),
            tooltip: 'Add Song to Queue',
          ),
          if (isHost)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Queue'),
                    content: const Text('Are you sure you want to clear the entire queue?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  queueNotifier.clearQueue();
                }
              },
              tooltip: 'Clear Queue',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const QueueDiagnosticsOverlay(),
            if (queueState.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (songs.isEmpty)
              Expanded(
                child: Center(
                  child: AppEmptyState.emptyQueue(
                    onAddSongs: () => _showAddSongsSheet(context),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (currentSong != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'NOW PLAYING',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      QueueTile(
                        title: currentSong.title,
                        artist: currentSong.artist,
                        duration: '${currentSong.duration.inMinutes}:${(currentSong.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        isCurrentlyPlaying: true,
                        isHost: isHost,
                        onTap: () {
                          if (sessionState.hasActiveSession) {
                            queueNotifier.selectSongIndex(effectiveIndex);
                          } else {
                            ref.read(playerNotifierProvider.notifier).playSongAtIndex(effectiveIndex);
                          }
                        },
                        onRemove: () => queueNotifier.removeSong(effectiveIndex),
                      ),
                    ],
                    if (upNext.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Text(
                          'UP NEXT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: upNext.length,
                        onReorder: (oldIndex, newIndex) {
                          if (!isHost) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Only the Room Host can reorder the shared queue.'),
                              ),
                            );
                            return;
                          }
                          final absoluteOld = effectiveIndex + 1 + oldIndex;
                          final absoluteNew = effectiveIndex + 1 + newIndex;
                          queueNotifier.reorderQueue(absoluteOld, absoluteNew);
                        },
                        itemBuilder: (context, index) {
                          final song = upNext[index];
                          final absoluteIndex = effectiveIndex + 1 + index;
                          return QueueTile(
                            key: ValueKey(song.id + index.toString()),
                            title: song.title,
                            artist: song.artist,
                            duration: '${song.duration.inMinutes}:${(song.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                            isCurrentlyPlaying: false,
                            isHost: isHost,
                            onTap: () {
                              if (sessionState.hasActiveSession) {
                                queueNotifier.selectSongIndex(absoluteIndex);
                              } else {
                                ref.read(playerNotifierProvider.notifier).playSongAtIndex(absoluteIndex);
                              }
                            },
                            onPlayNext: () => queueNotifier.playNext(song),
                            onRemove: () => queueNotifier.removeSong(absoluteIndex),
                            dragHandle: isHost
                                ? ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondaryDark),
                                  )
                                : null,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
