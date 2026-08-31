import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/player/data/repositories/music_repository_impl.dart';
import 'package:soulsync/features/player/domain/entities/album_entity.dart';
import 'package:soulsync/features/player/domain/entities/artist_entity.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

class MusicApiRepositoryImpl implements MusicRepository {
  final DioClient _dioClient;
  final MockMusicRepositoryImpl _fallbackMock = MockMusicRepositoryImpl();

  MusicApiRepositoryImpl(this._dioClient);

  @override
  Future<List<SongEntity>> getLocalSongs() async {
    try {
      await _dioClient.get<Map<String, dynamic>>('/songs');
      return await _fallbackMock.getLocalSongs();
    } catch (_) {
      return await _fallbackMock.getLocalSongs();
    }
  }

  @override
  Future<SongEntity?> getSongById(String id) async {
    try {
      await _dioClient.get<Map<String, dynamic>>('/songs/$id');
      return await _fallbackMock.getSongById(id);
    } catch (_) {
      return await _fallbackMock.getSongById(id);
    }
  }

  @override
  Future<List<ArtistEntity>> getArtists() async {
    try {
      await _dioClient.get<Map<String, dynamic>>('/artists');
      return await _fallbackMock.getArtists();
    } catch (_) {
      return await _fallbackMock.getArtists();
    }
  }

  @override
  Future<List<AlbumEntity>> getAlbums() async {
    try {
      await _dioClient.get<Map<String, dynamic>>('/albums');
      return await _fallbackMock.getAlbums();
    } catch (_) {
      return await _fallbackMock.getAlbums();
    }
  }

  @override
  Future<List<SongEntity>> getFavoriteSongs() async {
    try {
      await _dioClient.get<Map<String, dynamic>>('/favorites');
      return await _fallbackMock.getFavoriteSongs();
    } catch (_) {
      return await _fallbackMock.getFavoriteSongs();
    }
  }

  @override
  Future<void> toggleFavorite(String songId) async {
    try {
      await _dioClient.post<dynamic>('/favorites/$songId/toggle');
      await _fallbackMock.toggleFavorite(songId);
    } catch (_) {
      await _fallbackMock.toggleFavorite(songId);
    }
  }

  @override
  Future<List<SongEntity>> searchSongs(String query) async {
    try {
      await _dioClient.get<Map<String, dynamic>>('/songs/search',
          queryParameters: {'q': query});
      return await _fallbackMock.searchSongs(query);
    } catch (_) {
      return await _fallbackMock.searchSongs(query);
    }
  }

  @override
  Future<List<SongEntity>> refreshLibrary() async {
    try {
      await _dioClient.post<dynamic>('/songs/refresh');
      return await _fallbackMock.refreshLibrary();
    } catch (_) {
      return await _fallbackMock.refreshLibrary();
    }
  }
}
