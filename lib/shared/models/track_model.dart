import 'package:flutter/foundation.dart';

@immutable
class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String streamUrl;
  final String? coverArtUrl;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.streamUrl,
    this.coverArtUrl,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      streamUrl: json['streamUrl'] as String,
      coverArtUrl: json['coverArtUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationMs': duration.inMilliseconds,
      'streamUrl': streamUrl,
      'coverArtUrl': coverArtUrl,
    };
  }
}
