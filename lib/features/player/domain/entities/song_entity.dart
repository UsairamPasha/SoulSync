import 'package:flutter/foundation.dart';

/// Domain entity representing a playable audio track in SoulSync with full metadata.
@immutable
class SongEntity {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int? albumId;
  final int? artistId;
  final String? artworkUrl;
  final String assetPath;
  final Duration duration;
  final int size;
  final DateTime? dateAdded;
  final DateTime? dateModified;
  final bool isFavorite;

  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumId,
    this.artistId,
    this.artworkUrl,
    required this.assetPath,
    required this.duration,
    this.size = 0,
    this.dateAdded,
    this.dateModified,
    this.isFavorite = false,
  });

  SongEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? albumId,
    int? artistId,
    String? artworkUrl,
    String? assetPath,
    Duration? duration,
    int? size,
    DateTime? dateAdded,
    DateTime? dateModified,
    bool? isFavorite,
  }) {
    return SongEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      assetPath: assetPath ?? this.assetPath,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
