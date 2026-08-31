import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/library_provider.dart';
import 'package:soulsync/features/player/presentation/providers/permission_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/player/presentation/widgets/album_tile.dart';
import 'package:soulsync/features/player/presentation/widgets/artist_tile.dart';
import 'package:soulsync/features/player/presentation/widgets/permission_view.dart';
import 'package:soulsync/features/player/presentation/widgets/song_tile.dart';
import 'package:soulsync/features/player/presentation/widgets/sort_bottom_sheet.dart';

import 'package:soulsync/shared/widgets/inputs/app_search_text_field.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';
import 'package:soulsync/shared/widgets/states/app_error_state.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _playSongList(List<SongEntity> songs, int startIndex) {
    final sessionState = ref.read(playbackSessionNotifierProvider);
    if (sessionState.hasActiveSession && startIndex >= 0 && startIndex < songs.length) {
      ref.read(playbackSessionNotifierProvider.notifier).play(songId: songs[startIndex].id, positionMs: 0);
    } else {
      final notifier = ref.read(playerNotifierProvider.notifier);
      notifier.playSongAtIndex(startIndex);
    }
  }

  void _showSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SortBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissionStatus = ref.watch(permissionNotifierProvider);

    if (permissionStatus == StoragePermissionStatus.denied ||
        permissionStatus == StoragePermissionStatus.permanentlyDenied) {
      return const AppScaffold(
        body: SafeArea(child: PermissionView()),
      );
    }

    final songsAsync = ref.watch(librarySongsProvider);
    final artistsAsync = ref.watch(artistsProvider);
    final albumsAsync = ref.watch(albumsProvider);
    final favoritesAsync = ref.watch(favoriteSongsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Music Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: _showSortSheet,
            tooltip: 'Sort Music',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(librarySongsProvider);
              ref.invalidate(artistsProvider);
              ref.invalidate(albumsProvider);
              ref.invalidate(favoriteSongsProvider);
              AppSnackBars.showInfo(context, 'Refreshed local media library.');
            },
            tooltip: 'Refresh Library',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Songs'),
            Tab(text: 'Artists'),
            Tab(text: 'Albums'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: AppSearchTextField(
                controller: _searchController,
                hintText: 'Search tracks, artists, albums...',
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: All Songs
                  songsAsync.when(
                    data: (songs) {
                      if (songs.isEmpty) {
                        return const AppEmptyState(
                          title: 'No Music Found',
                          description:
                              'Add MP3 files to your device storage to see them here.',
                          icon: Icons.music_off_rounded,
                        );
                      }

                      final recentlyAdded = songs.take(5).toList();

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(librarySongsProvider);
                        },
                        child: ListView(
                          padding: AppSpacing.paddingLG,
                          children: [
                            // Recently Added Section
                            if (recentlyAdded.isNotEmpty) ...[
                              Text(
                                'Recently Added',
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                              AppSpacing.vGapSM,
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recentlyAdded.length,
                                  itemBuilder: (context, index) {
                                    final song = recentlyAdded[index];
                                    return GestureDetector(
                                      onTap: () => _playSongList(songs, index),
                                      child: Container(
                                        width: 140,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        padding: AppSpacing.paddingSM,
                                        decoration: BoxDecoration(
                                          color: context
                                              .customColors.cardBackground,
                                          borderRadius: AppRadius.borderMD,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.music_note_rounded,
                                              color: AppColors.primary,
                                              size: 32,
                                            ),
                                            const Spacer(),
                                            Text(
                                              song.title,
                                              style: context
                                                  .textTheme.labelMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              song.artist,
                                              style: context
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: context.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              AppSpacing.vGapLG,
                            ],

                            // All Songs Section Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'All Songs (${songs.length})',
                                  style:
                                      context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.vGapSM,

                            // Songs List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return SongTile(
                                  song: song,
                                  onTap: () => _playSongList(songs, index),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: AppCircularLoader()),
                    error: (err, stack) => Center(
                      child: AppErrorState.generic(
                        message: 'Failed to scan local music library',
                        onRetry: () => ref.invalidate(librarySongsProvider),
                      ),
                    ),
                  ),

                  // Tab 2: Artists
                  artistsAsync.when(
                    data: (artists) {
                      if (artists.isEmpty) {
                        return const AppEmptyState(
                          title: 'No Artists Found',
                          description:
                              'Artists will be listed here after scanning device music.',
                          icon: Icons.person_off_rounded,
                        );
                      }
                      return ListView.builder(
                        padding: AppSpacing.paddingLG,
                        itemCount: artists.length,
                        itemBuilder: (context, index) {
                          final artist = artists[index];
                          return ArtistTile(
                            artist: artist,
                            onTap: () {
                              ref.read(searchQueryProvider.notifier).state =
                                  artist.name;
                              _tabController.animateTo(0);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: AppCircularLoader()),
                    error: (err, stack) => Center(
                      child: AppErrorState.generic(
                        message: 'Failed to load artists',
                        onRetry: () => ref.invalidate(artistsProvider),
                      ),
                    ),
                  ),

                  // Tab 3: Albums
                  albumsAsync.when(
                    data: (albums) {
                      if (albums.isEmpty) {
                        return const AppEmptyState(
                          title: 'No Albums Found',
                          description:
                              'Albums will be listed here after scanning device music.',
                          icon: Icons.album_outlined,
                        );
                      }
                      return GridView.builder(
                        padding: AppSpacing.paddingLG,
                        itemCount: albums.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final album = albums[index];
                          return AlbumTile(
                            album: album,
                            onTap: () {
                              ref.read(searchQueryProvider.notifier).state =
                                  album.title;
                              _tabController.animateTo(0);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: AppCircularLoader()),
                    error: (err, stack) => Center(
                      child: AppErrorState.generic(
                        message: 'Failed to load albums',
                        onRetry: () => ref.invalidate(albumsProvider),
                      ),
                    ),
                  ),

                  // Tab 4: Favorites
                  favoritesAsync.when(
                    data: (favSongs) {
                      if (favSongs.isEmpty) {
                        return const AppEmptyState(
                          title: 'No Favorites Yet',
                          description:
                              'Tap the heart icon on any song to add it to your couple favorites.',
                          icon: Icons.favorite_border_rounded,
                        );
                      }
                      return ListView.builder(
                        padding: AppSpacing.paddingLG,
                        itemCount: favSongs.length,
                        itemBuilder: (context, index) {
                          final song = favSongs[index];
                          return SongTile(
                            song: song,
                            onTap: () => _playSongList(favSongs, index),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: AppCircularLoader()),
                    error: (err, stack) => Center(
                      child: AppErrorState.generic(
                        message: 'Failed to load favorite songs',
                        onRetry: () => ref.invalidate(favoriteSongsProvider),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
