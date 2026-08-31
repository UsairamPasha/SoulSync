import 'package:flutter/foundation.dart';
import 'package:soulsync/features/player/domain/entities/song_entity.dart';

abstract class NotificationService {
  Future<void> showPlaybackNotification(SongEntity song, bool isPlaying);
  Future<void> clearNotification();
}

class LocalNotificationServiceStub implements NotificationService {
  @override
  Future<void> showPlaybackNotification(SongEntity song, bool isPlaying) async {
    debugPrint(
        '[LocalNotificationServiceStub] Playing notification: ${song.title} (isPlaying: $isPlaying)');
  }

  @override
  Future<void> clearNotification() async {
    debugPrint('[LocalNotificationServiceStub] Notification cleared.');
  }
}
