import 'package:flutter/foundation.dart';

enum RepeatModeEnum { off, all, one }

/// Domain entity representing real-time audio playback state.
@immutable
class PlaybackStateEntity {
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;
  final double speed;
  final bool isShuffle;
  final RepeatModeEnum repeatMode;

  const PlaybackStateEntity({
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.isShuffle = false,
    this.repeatMode = RepeatModeEnum.off,
  });

  PlaybackStateEntity copyWith({
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    bool? isShuffle,
    RepeatModeEnum? repeatMode,
  }) {
    return PlaybackStateEntity(
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}
