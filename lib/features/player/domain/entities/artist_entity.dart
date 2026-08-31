import 'package:flutter/foundation.dart';

@immutable
class ArtistEntity {
  final int id;
  final String name;
  final int numberOfAlbums;
  final int numberOfTracks;

  const ArtistEntity({
    required this.id,
    required this.name,
    this.numberOfAlbums = 0,
    this.numberOfTracks = 0,
  });
}
