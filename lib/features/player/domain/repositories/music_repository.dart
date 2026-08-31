import 'package:soulsync/features/player/domain/entities/album_entity.dart';
import 'package:soulsync/features/player/domain/entities/artist_entity.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

abstract class MusicRepository {
  Future<List<SongEntity>> getLocalSongs();
  Future<SongEntity?> getSongById(String id);
  Future<List<ArtistEntity>> getArtists();
  Future<List<AlbumEntity>> getAlbums();
  Future<List<SongEntity>> getFavoriteSongs();
  Future<void> toggleFavorite(String songId);
  Future<List<SongEntity>> searchSongs(String query);
  Future<List<SongEntity>> refreshLibrary();
}
