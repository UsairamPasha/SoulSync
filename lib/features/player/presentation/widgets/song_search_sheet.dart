import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/library_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/song_tile.dart';
import 'package:soulsync/features/queue/presentation/providers/queue_provider.dart';
import 'package:soulsync/shared/widgets/inputs/app_search_text_field.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';

class SongSearchSheet extends ConsumerStatefulWidget {
  const SongSearchSheet({super.key});

  @override
  ConsumerState<SongSearchSheet> createState() => _SongSearchSheetState();
}

class _SongSearchSheetState extends ConsumerState<SongSearchSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSongSelected(SongEntity song) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded, color: Colors.green),
              title: const Text('Play Now (Room Synced)'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(playerNotifierProvider.notifier).playSong(song);
                final sessionState = ref.read(playbackSessionNotifierProvider);
                if (sessionState.hasActiveSession) {
                  ref
                      .read(playbackSessionNotifierProvider.notifier)
                      .play(songId: song.id, positionMs: 0);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded, color: Colors.blue),
              title: const Text('Play Next in Shared Queue'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(sharedQueueNotifierProvider.notifier).playNext(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${song.title}" to Play Next.')),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_to_photos_rounded, color: Colors.purple),
              title: const Text('Add to End of Shared Queue'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(sharedQueueNotifierProvider.notifier).addSong(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${song.title}" to Shared Queue.')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(librarySongsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                color: context.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGapMD,
          Text(
            'Search & Play Songs',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapSM,
          AppSearchTextField(
            controller: _searchController,
            hintText: 'Search title, artist, album...',
            onChanged: (val) {
              setState(() {
                _query = val.trim().toLowerCase();
              });
            },
          ),
          AppSpacing.vGapMD,
          Expanded(
            child: songsAsync.when(
              data: (allSongs) {
                final filtered = _query.isEmpty
                    ? allSongs
                    : allSongs.where((s) {
                        final title = s.title.toLowerCase();
                        final artist = s.artist.toLowerCase();
                        final album = s.album.toLowerCase();
                        return title.contains(_query) ||
                            artist.contains(_query) ||
                            album.contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    title: 'No Matching Songs',
                    description: 'Try searching for a different song or artist.',
                    icon: Icons.search_off_rounded,
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final song = filtered[index];
                    return SongTile(
                      song: song,
                      onTap: () => _onSongSelected(song),
                    );
                  },
                );
              },
              loading: () => const Center(child: AppCircularLoader()),
              error: (err, stack) => Center(
                child: Text('Error loading songs: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
