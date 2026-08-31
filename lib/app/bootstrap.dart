import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/logger/app_logger.dart';
import 'package:soulsync/features/player/data/services/media_notification_service.dart';

/// Global AudioHandler instance initialized before runApp().
AudioHandler? gAudioHandler;

/// Bootstraps the Flutter application with global error handling, AudioService init, and ProviderScope.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
        'Flutter Framework Error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error('Unhandled Platform Error', error, stack);
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Bootstrapping SoulSync application...');

  try {
    debugPrint('[CRITICAL_BOOTSTRAP] Starting AudioService.init...');
    gAudioHandler = await AudioService.init(
      builder: () => SoulSyncAudioHandler.instance,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.soulsync.channel.audio',
        androidNotificationChannelName: 'SoulSync Music Playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        notificationColor: Color(0xFF6C5CE7),
      ),
    );
    debugPrint('[CRITICAL_BOOTSTRAP] AudioService.init SUCCESS! gAudioHandler: $gAudioHandler');
    AppLogger.info('[Bootstrap] AudioService.init completed synchronously before runApp! gAudioHandler: $gAudioHandler');
  } catch (e, st) {
    debugPrint('[CRITICAL_BOOTSTRAP_ERROR] AudioService.init EXCEPTION: $e\n$st');
    AppLogger.error('[Bootstrap] AudioService.init error', e, st);
  }

  runApp(
    ProviderScope(
      child: await builder(),
    ),
  );
}
