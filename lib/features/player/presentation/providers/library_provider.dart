import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/player/data/repositories/music_repository_impl.dart';
import 'package:soulsync/features/player/domain/entities/album_entity.dart';
import 'package:soulsync/features/player/domain/entities/artist_entity.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';

final sortOptionProvider = StateProvider<SortOption>((ref) {
  return SortOption.name;
});

final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

final librarySongsProvider = FutureProvider<List<SongEntity>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider) as LocalMusicRepositoryImpl;
  final sort = ref.watch(sortOptionProvider);
  final query = ref.watch(searchQueryProvider);

  repo.setSortOption(sort);
  return await repo.searchSongs(query);
});

final artistsProvider = FutureProvider<List<ArtistEntity>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return await repo.getArtists();
});

final albumsProvider = FutureProvider<List<AlbumEntity>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return await repo.getAlbums();
});

final favoriteSongsProvider = FutureProvider<List<SongEntity>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return await repo.getFavoriteSongs();
});
