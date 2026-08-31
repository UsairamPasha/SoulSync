import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:soulsync/features/player/data/services/playback_settings_service.dart';
import 'package:soulsync/features/player/domain/entities/playback_settings.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';

class PlaybackSettingsNotifier extends StateNotifier<PlaybackSettings> {
  final PlaybackSettingsService _service;
  final Ref _ref;

  PlaybackSettingsNotifier(this._service, this._ref)
      : super(const PlaybackSettings()) {
    _load();
  }

  Future<void> _load() async {
    final loaded = await _service.loadSettings();
    state = loaded;
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.setVolume(state.volume);
    await audioService.setSpeed(state.speed);
    await audioService.setLoopMode(state.repeatMode);
    await audioService.setShuffleModeEnabled(state.isShuffle);
  }

  Future<void> setShuffleFromRemote(bool enabled) async {
    state = state.copyWith(isShuffle: enabled);
    await _service.saveSettings(state);
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeatFromRemote(LoopMode mode) async {
    state = state.copyWith(repeatMode: mode);
    await _service.saveSettings(state);
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.setLoopMode(mode);
  }

  Future<void> toggleShuffle() async {
    final newShuffle = !state.isShuffle;
    state = state.copyWith(isShuffle: newShuffle);
    await _service.saveSettings(state);
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.setShuffleModeEnabled(newShuffle);

    final ws = _ref.read(webSocketServiceProvider);
    ws.send({
      'type': 'playback_settings',
      'isShuffle': newShuffle,
      'repeatMode': state.repeatMode.name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> cycleRepeatMode() async {
    LoopMode next;
    if (state.repeatMode == LoopMode.off) {
      next = LoopMode.all;
    } else if (state.repeatMode == LoopMode.all) {
      next = LoopMode.one;
    } else {
      next = LoopMode.off;
    }

    state = state.copyWith(repeatMode: next);
    await _service.saveSettings(state);
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.setLoopMode(next);

    final ws = _ref.read(webSocketServiceProvider);
    ws.send({
      'type': 'playback_settings',
      'isShuffle': state.isShuffle,
      'repeatMode': next.name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _service.saveSettings(state);
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _service.saveSettings(state);
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.setVolume(volume);
  }
}

final playbackSettingsServiceProvider =
    Provider<PlaybackSettingsService>((ref) {
  return PlaybackSettingsService();
});

final playbackSettingsNotifierProvider =
    StateNotifierProvider<PlaybackSettingsNotifier, PlaybackSettings>((ref) {
  final service = ref.watch(playbackSettingsServiceProvider);
  return PlaybackSettingsNotifier(service, ref);
});
