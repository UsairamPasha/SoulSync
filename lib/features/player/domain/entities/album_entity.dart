import 'package:flutter/foundation.dart';

@immutable
class AlbumEntity {
  final int id;
  final String title;
  final String artist;
  final String? artworkUrl;
  final int numberOfSongs;

  const AlbumEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.artworkUrl,
    this.numberOfSongs = 0,
  });
}
