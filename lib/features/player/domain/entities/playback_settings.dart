import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

@immutable
class PlaybackSettings {
  final bool isShuffle;
  final LoopMode repeatMode;
  final double speed;
  final double volume;

  const PlaybackSettings({
    this.isShuffle = false,
    this.repeatMode = LoopMode.off,
    this.speed = 1.0,
    this.volume = 1.0,
  });

  PlaybackSettings copyWith({
    bool? isShuffle,
    LoopMode? repeatMode,
    double? speed,
    double? volume,
  }) {
    return PlaybackSettings(
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
    );
  }
}
