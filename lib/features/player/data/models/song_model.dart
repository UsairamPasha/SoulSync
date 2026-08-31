import 'package:flutter/foundation.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

@immutable
class SongModel extends SongEntity {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.album,
    super.albumId,
    super.artistId,
    super.artworkUrl,
    required super.assetPath,
    required super.duration,
    super.size,
    super.dateAdded,
    super.dateModified,
    super.isFavorite,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      albumId: json['albumId'] as int?,
      artistId: json['artistId'] as int?,
      artworkUrl: json['artworkUrl'] as String?,
      assetPath: json['assetPath'] as String,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 180),
      size: json['size'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumId': albumId,
      'artistId': artistId,
      'artworkUrl': artworkUrl,
      'assetPath': assetPath,
      'durationSeconds': duration.inSeconds,
      'size': size,
      'isFavorite': isFavorite,
    };
  }
}
