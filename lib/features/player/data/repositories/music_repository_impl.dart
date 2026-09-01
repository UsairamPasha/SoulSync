import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:soulsync/core/constants/api_constants.dart';
import 'package:soulsync/features/player/data/datasources/local_music_datasource.dart';
import 'package:soulsync/features/player/data/models/song_model.dart';
import 'package:soulsync/features/player/data/services/favorites_storage_service.dart';
import 'package:soulsync/features/player/domain/entities/album_entity.dart';
import 'package:soulsync/features/player/domain/entities/artist_entity.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';
import 'package:soulsync/features/player/domain/repositories/music_repository.dart';

import 'package:soulsync/core/config/app_config.dart';

enum SortOption { name, artist, album, duration, dateAdded }

class LocalMusicRepositoryImpl implements MusicRepository {
  final LocalMusicDataSource _dataSource;
  final FavoritesStorageService _favoritesService;
  final AppConfig? _config;

  List<SongEntity>? _cachedSongs;
  List<SongEntity>? _cachedAssetCatalog;
  SortOption _currentSort = SortOption.name;

  LocalMusicRepositoryImpl({
    LocalMusicDataSource? dataSource,
    FavoritesStorageService? favoritesService,
    AppConfig? config,
  })  : _dataSource = dataSource ?? LocalMusicDataSourceImpl(),
        _favoritesService = favoritesService ?? FavoritesStorageService(),
        _config = config;

  void setSortOption(SortOption option) {
    _currentSort = option;
    if (_cachedSongs != null) {
      _applySort(_cachedSongs!);
    }
  }

  void _applySort(List<SongEntity> songs) {
    switch (_currentSort) {
      case SortOption.name:
        songs.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.artist:
        songs.sort(
            (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case SortOption.album:
        songs.sort(
            (a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()));
        break;
      case SortOption.duration:
        songs.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case SortOption.dateAdded:
        songs.sort((a, b) => (b.dateAdded ?? DateTime(1970))
            .compareTo(a.dateAdded ?? DateTime(1970)));
        break;
    }
  }

  @override
  Future<List<SongEntity>> getLocalSongs() async {
    return await refreshLibrary();
  }

  Future<List<SongEntity>> _loadAssetCatalog(Set<String> favoriteIds) async {
    if (_cachedAssetCatalog != null && _cachedAssetCatalog!.isNotEmpty) {
      return _cachedAssetCatalog!
          .map((s) => s.copyWith(
                isFavorite: favoriteIds.contains(s.id),
              ))
          .toList();
    }

    final List<SongEntity> catalog = [];

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final musicPaths = manifest
          .listAssets()
          .where((path) =>
              path.startsWith('assets/music/') &&
              path.toLowerCase().endsWith('.mp3'))
          .toList();

      musicPaths.sort((a, b) => a.compareTo(b));

      int index = 1;
      for (final path in musicPaths) {
        final filename = path.split('/').last;
        final nameWithoutExt = filename.substring(0, filename.length - 4);

        String songId;
        String title;
        String artist;

        if (filename == 'sample_1.mp3') {
          songId = 'song_1';
          title = 'Sample 1';
          artist = 'SoulSync Audio';
        } else if (filename == 'sample_2.mp3') {
          songId = 'song_2';
          title = 'Sample 2';
          artist = 'SoulSync Audio';
        } else if (filename == 'sample_3.mp3') {
          songId = 'song_3';
          title = 'Sample 3';
          artist = 'SoulSync Audio';
        } else {
          songId = 'asset_music_$index';
          final parts = nameWithoutExt.split(' - ');
          if (parts.length >= 2) {
            artist = parts[0].trim();
            title = parts.sublist(1).join(' - ').trim();
          } else {
            title = nameWithoutExt.trim();
            artist = 'SoulSync Music';
          }
        }

        catalog.add(
          SongModel(
            id: songId,
            title: title,
            artist: artist,
            album: 'SoulSync Library',
            assetPath: path,
            duration: const Duration(seconds: 210),
            isFavorite:
                favoriteIds.contains(songId) || favoriteIds.contains(path),
          ),
        );
        index++;
      }
    } catch (e) {
      debugPrint('[LocalMusicRepository] AssetManifest scan fallback: $e');
    }

    if (catalog.isEmpty) {
      catalog.addAll(_defaultFallbackCatalog(favoriteIds));
    }

    _cachedAssetCatalog = catalog;
    return catalog;
  }

  Future<List<SongEntity>> _fetchRemoteCatalog(Set<String> favoriteIds) async {
    try {
      final dio = Dio(BaseOptions(
        validateStatus: (status) => status != null && status < 500,
      ));
      final apiBaseUrl = _config?.apiBaseUrl ?? ApiConstants.baseUrl;
      final activeHost =
          Uri.parse(_config?.baseUrl ?? ApiConstants.baseUrl).host;

      final response = await dio
          .get<Map<String, dynamic>>(
            '$apiBaseUrl/music/',
            options: Options(headers: {
              if (!kIsWeb) ...{
                'ngrok-skip-browser-warning': '69420',
                'User-Agent': 'SoulSyncApp/1.0',
              },
            }),
          )
          .timeout(const Duration(seconds: 15));
      final data = response.data;
      if (data != null && data['data'] != null) {
        final list = data['data'] as List<dynamic>? ?? [];
        debugPrint(
            '[LocalMusicRepository] Successfully fetched ${list.length} remote cloud songs!');
        return list.map((item) {
          final id = item['id'] as String? ?? '';
          var streamUrl = item['stream_url'] as String? ??
              item['asset_path'] as String? ??
              '';
          if (streamUrl.contains('trycloudflare.com') &&
              activeHost.isNotEmpty) {
            try {
              final parsed = Uri.parse(streamUrl);
              streamUrl =
                  parsed.replace(host: activeHost, scheme: 'https').toString();
            } catch (_) {}
          }
          return SongModel(
            id: id,
            title: item['title'] as String? ?? 'Track',
            artist: item['artist'] as String? ?? 'SoulSync Cloud',
            album: item['album'] as String? ?? 'SoulSync Cloud Library',
            assetPath: streamUrl,
            duration: Duration(
                milliseconds: (item['duration_ms'] as num? ?? 210000).toInt()),
            isFavorite:
                favoriteIds.contains(id) || favoriteIds.contains(streamUrl),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[LocalMusicRepository] Remote music API fetch error: $e');
    }
    return [];
  }

  @override
  Future<List<SongEntity>> refreshLibrary() async {
    final favoriteIds = await _favoritesService.getFavoriteSongIds();
    final List<SongEntity> sampleCatalog = await _loadAssetCatalog(favoriteIds);
    final List<SongEntity> remoteCatalog =
        await _fetchRemoteCatalog(favoriteIds);
    final List<SongEntity> mediaStoreSongs = [];

    final Map<String, SongEntity> songMap = {};
    for (final r in remoteCatalog) {
      songMap[r.id] = r;
    }
    for (final s in sampleCatalog) {
      if (!songMap.containsKey(s.id)) {
        songMap[s.id] = s;
      }
    }

    final combinedCatalog = songMap.values.toList();

    // 1. Attempt device MediaStore query
    try {
      final deviceSongs = await _dataSource.querySongs();
      if (deviceSongs.isNotEmpty) {
        for (final s in deviceSongs) {
          final isFav = favoriteIds.contains(s.id.toString());
          mediaStoreSongs.add(
            SongEntity(
              id: 'mediastore_${s.id}',
              title: s.title.isNotEmpty ? s.title : 'Unknown Track',
              artist: (s.artist.isNotEmpty && s.artist != '<unknown>')
                  ? s.artist
                  : 'Unknown Artist',
              album: (s.album.isNotEmpty && s.album != '<unknown>')
                  ? s.album
                  : 'Unknown Album',
              albumId: s.albumId,
              artistId: s.artistId,
              assetPath: s.data,
              duration: Duration(milliseconds: s.duration ?? 0),
              size: s.size,
              dateAdded: s.dateAdded != null
                  ? DateTime.fromMillisecondsSinceEpoch(s.dateAdded! * 1000)
                  : null,
              isFavorite: isFav,
            ),
          );
        }
      }
    } catch (_) {}

    _applySort(mediaStoreSongs);

    _cachedSongs = [...combinedCatalog, ...mediaStoreSongs];
    return _cachedSongs!;
  }

  List<SongEntity> _defaultFallbackCatalog(Set<String> favoriteIds) {
    return [
      SongModel(
        id: 'song_1',
        title: 'Sample 1',
        artist: 'SoulSync Audio',
        album: 'Local Assets',
        assetPath: 'assets/music/sample_1.mp3',
        duration: const Duration(seconds: 180),
        isFavorite:
            favoriteIds.contains('song_1') || favoriteIds.contains('s1'),
      ),
      SongModel(
        id: 'song_2',
        title: 'Sample 2',
        artist: 'SoulSync Audio',
        album: 'Local Assets',
        assetPath: 'assets/music/sample_2.mp3',
        duration: const Duration(seconds: 210),
        isFavorite:
            favoriteIds.contains('song_2') || favoriteIds.contains('s2'),
      ),
      SongModel(
        id: 'song_3',
        title: 'Sample 3',
        artist: 'SoulSync Audio',
        album: 'Local Assets',
        assetPath: 'assets/music/sample_3.mp3',
        duration: const Duration(seconds: 195),
        isFavorite:
            favoriteIds.contains('song_3') || favoriteIds.contains('s3'),
      ),
    ];
  }

  @override
  Future<SongEntity?> getSongById(String id) async {
    var songs = await getLocalSongs();
    try {
      return songs.firstWhere((s) => s.id == id || s.assetPath == id);
    } catch (_) {}

    // If not found, force refresh library to load 428 cloud songs
    songs = await refreshLibrary();
    try {
      return songs.firstWhere((s) => s.id == id || s.assetPath == id);
    } catch (_) {}

    final activeBaseUrl = _config?.baseUrl ?? ApiConstants.baseUrl;
    final cleanBase = activeBaseUrl.replaceFirst('/api/v1', '');

    if (id.startsWith('http://') || id.startsWith('https://')) {
      return SongModel(
        id: id,
        title: 'Cloud Track',
        artist: 'SoulSync Music',
        album: 'SoulSync Cloud Library',
        assetPath: id,
        duration: const Duration(seconds: 210),
      );
    }

    if (id.startsWith('remote_music_')) {
      final streamUrl = '$cleanBase/media/music/$id.mp3';
      return SongModel(
        id: id,
        title: 'Track ${id.replaceAll('remote_music_', '')}',
        artist: 'SoulSync Cloud Library',
        album: 'SoulSync Cloud',
        assetPath: streamUrl,
        duration: const Duration(seconds: 210),
      );
    }

    return null;
  }

  @override
  Future<List<ArtistEntity>> getArtists() async {
    final songs = await getLocalSongs();
    final Map<String, List<SongEntity>> artistMap = {};

    for (final song in songs) {
      artistMap.putIfAbsent(song.artist, () => []).add(song);
    }

    final List<ArtistEntity> artists = [];
    int idCounter = 1;
    artistMap.forEach((name, songList) {
      final albumCount = songList.map((s) => s.album).toSet().length;
      artists.add(
        ArtistEntity(
          id: songList.first.artistId ?? idCounter++,
          name: name,
          numberOfAlbums: albumCount,
          numberOfTracks: songList.length,
        ),
      );
    });

    artists
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return artists;
  }

  @override
  Future<List<AlbumEntity>> getAlbums() async {
    final songs = await getLocalSongs();
    final Map<String, List<SongEntity>> albumMap = {};

    for (final song in songs) {
      albumMap.putIfAbsent(song.album, () => []).add(song);
    }

    final List<AlbumEntity> albums = [];
    int idCounter = 1;
    albumMap.forEach((title, songList) {
      albums.add(
        AlbumEntity(
          id: songList.first.albumId ?? idCounter++,
          title: title,
          artist: songList.first.artist,
          numberOfSongs: songList.length,
        ),
      );
    });

    albums
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return albums;
  }

  @override
  Future<List<SongEntity>> getFavoriteSongs() async {
    final songs = await getLocalSongs();
    return songs.where((s) => s.isFavorite).toList();
  }

  @override
  Future<void> toggleFavorite(String songId) async {
    final isFav = await _favoritesService.toggleFavorite(songId);
    if (_cachedSongs != null) {
      final index = _cachedSongs!.indexWhere((s) => s.id == songId);
      if (index != -1) {
        _cachedSongs![index] = _cachedSongs![index].copyWith(isFavorite: isFav);
      }
    }
  }

  @override
  Future<List<SongEntity>> searchSongs(String query) async {
    final songs = await getLocalSongs();
    if (query.trim().isEmpty) return songs;
    final q = query.trim().toLowerCase();

    return songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q) ||
          s.album.toLowerCase().contains(q);
    }).toList();
  }
}

// Retain MockMusicRepositoryImpl alias for backwards compatibility
typedef MockMusicRepositoryImpl = LocalMusicRepositoryImpl;
