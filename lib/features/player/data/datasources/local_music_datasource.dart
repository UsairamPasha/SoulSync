import 'package:flutter/services.dart';

class DeviceSongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int? albumId;
  final int? artistId;
  final int? duration;
  final String data;
  final int size;
  final int? dateAdded;

  const DeviceSongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumId,
    this.artistId,
    this.duration,
    required this.data,
    required this.size,
    this.dateAdded,
  });

  factory DeviceSongModel.fromMap(Map<dynamic, dynamic> map) {
    return DeviceSongModel(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String? ?? 'Unknown Track',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? 'Unknown Album',
      albumId: (map['albumId'] as num?)?.toInt(),
      artistId: (map['artistId'] as num?)?.toInt(),
      duration: (map['duration'] as num?)?.toInt(),
      data: map['data'] as String? ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
      dateAdded: (map['dateAdded'] as num?)?.toInt(),
    );
  }
}

class DeviceArtistModel {
  final int id;
  final String artist;
  final int numberOfAlbums;
  final int numberOfTracks;

  const DeviceArtistModel({
    required this.id,
    required this.artist,
    required this.numberOfAlbums,
    required this.numberOfTracks,
  });

  factory DeviceArtistModel.fromMap(Map<dynamic, dynamic> map) {
    return DeviceArtistModel(
      id: (map['id'] as num).toInt(),
      artist: map['artist'] as String? ?? 'Unknown Artist',
      numberOfAlbums: (map['numberOfAlbums'] as num?)?.toInt() ?? 0,
      numberOfTracks: (map['numberOfTracks'] as num?)?.toInt() ?? 0,
    );
  }
}

class DeviceAlbumModel {
  final int id;
  final String album;
  final String artist;
  final int numberOfSongs;

  const DeviceAlbumModel({
    required this.id,
    required this.album,
    required this.artist,
    required this.numberOfSongs,
  });

  factory DeviceAlbumModel.fromMap(Map<dynamic, dynamic> map) {
    return DeviceAlbumModel(
      id: (map['id'] as num).toInt(),
      album: map['album'] as String? ?? 'Unknown Album',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      numberOfSongs: (map['numberOfSongs'] as num?)?.toInt() ?? 0,
    );
  }
}

abstract class LocalMusicDataSource {
  Future<List<DeviceSongModel>> querySongs();
  Future<List<DeviceArtistModel>> queryArtists();
  Future<List<DeviceAlbumModel>> queryAlbums();
}

class LocalMusicDataSourceImpl implements LocalMusicDataSource {
  static const MethodChannel _channel = MethodChannel('soulsync/media_scanner');

  @override
  Future<List<DeviceSongModel>> querySongs() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('querySongs');
      if (result == null) return [];
      return result
          .cast<Map<dynamic, dynamic>>()
          .map((m) => DeviceSongModel.fromMap(m))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DeviceArtistModel>> queryArtists() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('queryArtists');
      if (result == null) return [];
      return result
          .cast<Map<dynamic, dynamic>>()
          .map((m) => DeviceArtistModel.fromMap(m))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DeviceAlbumModel>> queryAlbums() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('queryAlbums');
      if (result == null) return [];
      return result
          .cast<Map<dynamic, dynamic>>()
          .map((m) => DeviceAlbumModel.fromMap(m))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
