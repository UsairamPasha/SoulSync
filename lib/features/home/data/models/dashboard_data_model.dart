import 'package:flutter/foundation.dart';

@immutable
class CurrentSongModel {
  final String title;
  final String artist;
  final String albumArtUrl;
  final Duration duration;
  final Duration currentPosition;
  final bool isPlaying;

  const CurrentSongModel({
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.duration,
    required this.currentPosition,
    this.isPlaying = false,
  });
}

@immutable
class CoupleStatusModel {
  final String partnerName;
  final String partnerAvatarUrl;
  final bool isOnline;
  final String roomName;
  final bool isSyncing;

  const CoupleStatusModel({
    required this.partnerName,
    required this.partnerAvatarUrl,
    required this.isOnline,
    required this.roomName,
    required this.isSyncing,
  });
}

@immutable
class ActivityItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String type; // 'song', 'chat', 'playlist'

  const ActivityItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.type,
  });
}

@immutable
class UserStatsModel {
  final int totalSongs;
  final int totalPlaylists;
  final int totalFavorites;
  final double listeningHours;

  const UserStatsModel({
    required this.totalSongs,
    required this.totalPlaylists,
    required this.totalFavorites,
    required this.listeningHours,
  });
}

@immutable
class DashboardDataModel {
  final CoupleStatusModel coupleStatus;
  final CurrentSongModel currentSong;
  final List<ActivityItemModel> recentActivities;
  final UserStatsModel stats;

  const DashboardDataModel({
    required this.coupleStatus,
    required this.currentSong,
    required this.recentActivities,
    required this.stats,
  });
}
