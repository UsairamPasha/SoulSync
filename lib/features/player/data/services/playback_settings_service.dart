import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulsync/features/player/domain/entities/playback_settings.dart';

class PlaybackSettingsService {
  static const _keyShuffle = 'soulsync_is_shuffle';
  static const _keyRepeatMode = 'soulsync_repeat_mode';
  static const _keySpeed = 'soulsync_speed';
  static const _keyVolume = 'soulsync_volume';

  Future<PlaybackSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shuffle = prefs.getBool(_keyShuffle) ?? false;
      final repeatIndex = prefs.getInt(_keyRepeatMode) ?? 0;
      final speed = prefs.getDouble(_keySpeed) ?? 1.0;
      final volume = prefs.getDouble(_keyVolume) ?? 1.0;

      LoopMode mode = LoopMode.off;
      if (repeatIndex == 1) mode = LoopMode.one;
      if (repeatIndex == 2) mode = LoopMode.all;

      return PlaybackSettings(
        isShuffle: shuffle,
        repeatMode: mode,
        speed: speed,
        volume: volume,
      );
    } catch (_) {
      return const PlaybackSettings();
    }
  }

  Future<void> saveSettings(PlaybackSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyShuffle, settings.isShuffle);

      int repeatIndex = 0;
      if (settings.repeatMode == LoopMode.one) repeatIndex = 1;
      if (settings.repeatMode == LoopMode.all) repeatIndex = 2;

      await prefs.setInt(_keyRepeatMode, repeatIndex);
      await prefs.setDouble(_keySpeed, settings.speed);
      await prefs.setDouble(_keyVolume, settings.volume);
    } catch (_) {}
  }
}
