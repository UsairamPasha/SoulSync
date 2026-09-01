import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// AudioPlayerService encapsulating just_audio and audio_session.
/// Hides all low-level plugin details from higher Clean Architecture layers.
class AudioPlayerService {
  final AudioPlayer _player;
  bool _isInitialized = false;
  String? _currentlyLoadedPath;

  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  AudioPlayer get player => _player;
  String? get currentlyLoadedPath => _currentlyLoadedPath;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));
      await session.setActive(true);
      await _player.setVolume(1.0);
      _isInitialized = true;
      debugPrint(
          '[AudioPlayerService] AudioSession configured & activated with Android media attributes.');
    } catch (e) {
      debugPrint('[AudioPlayerService] AudioSession configuration warning: $e');
      _isInitialized = true;
    }
  }

  Uint8List _stripID3Header(Uint8List bytes) {
    if (bytes.length > 10 &&
        bytes[0] == 0x49 && // 'I'
        bytes[1] == 0x44 && // 'D'
        bytes[2] == 0x33) { // '3'
      final tagSize = ((bytes[6] & 0x7f) << 21) |
          ((bytes[7] & 0x7f) << 14) |
          ((bytes[8] & 0x7f) << 7) |
          (bytes[9] & 0x7f);
      final offset = 10 + tagSize;
      if (offset > 0 && offset < bytes.length) {
        debugPrint(
            '[AudioPlayerService] Stripped embedded ID3 tag header ($offset bytes)');
        return bytes.sublist(offset);
      }
    }
    return bytes;
  }

  Completer<Duration?>? _activeLoadCompleter;
  String? _activeLoadPath;

  Future<Duration?> loadAsset(String path) async {
    await initialize();

    debugPrint('[AudioEngine] Loading asset: $path');

    if (_currentlyLoadedPath == path &&
        _player.processingState != ProcessingState.idle &&
        _player.duration != null &&
        _player.duration! > Duration.zero) {
      debugPrint(
          '[AudioEngine] Asset loaded (cached): $path (Duration: ${_player.duration}, Position: ${_player.position})');
      return _player.duration;
    }

    if (_activeLoadCompleter != null) {
      if (_activeLoadPath == path) {
        debugPrint('[AudioEngine] Concurrent load for same asset detected ($path).');
        return await _activeLoadCompleter!.future;
      } else {
        debugPrint('[AudioEngine] Track switch requested ($path). Cancelling previous load of $_activeLoadPath.');
        if (!_activeLoadCompleter!.isCompleted) {
          _activeLoadCompleter!.complete(null);
        }
      }
    }

    final completer = Completer<Duration?>();
    _activeLoadCompleter = completer;
    _activeLoadPath = path;

    try {
      Duration? duration;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        debugPrint('[AudioEngine] Loading HTTP Audio Source: $path');
        try {
          final cleanUri = Uri.tryParse(path) ?? Uri.parse(Uri.encodeFull(path));
          final audioSource = AudioSource.uri(
            cleanUri,
            headers: kIsWeb
                ? null
                : const {
                    'ngrok-skip-browser-warning': '69420',
                    'User-Agent': 'SoulSyncApp/1.0',
                  },
          );

          duration = await _player.setAudioSource(audioSource);
          _currentlyLoadedPath = path;
          if (!completer.isCompleted) completer.complete(duration);
          return duration ?? const Duration(seconds: 210);
        } catch (e) {
          debugPrint('[AudioEngine] Error parsing or loading HTTP URI ($path): $e');
          rethrow;
        }
      } else if (kIsWeb) {
        debugPrint('[AudioEngine] Loading Web Asset Audio Source: $path');
        duration = await _player.setAsset(path);
        _currentlyLoadedPath = path;
        if (!completer.isCompleted) completer.complete(duration);
        return duration ?? const Duration(seconds: 210);
      } else if (path.startsWith('assets/')) {
        final tempDir = await getTemporaryDirectory();
        final filename = path.split('/').last;
        final tempFile = File('${tempDir.path}/$filename');

        if (!await tempFile.exists() || await tempFile.length() == 0) {
          debugPrint('[AudioEngine] Extracting asset bytes to cache: $filename');
          final byteData = await rootBundle.load(path);
          final rawBytes = byteData.buffer.asUint8List();
          final cleanBytes = _stripID3Header(rawBytes);
          await tempFile.writeAsBytes(cleanBytes, flush: true);
        }

        int attempt = 0;
        while (attempt < 3) {
          attempt++;
          try {
            duration = await _player.setFilePath(tempFile.path);
            break;
          } catch (e) {
            if (e.toString().contains('interrupted') && attempt < 3) {
              debugPrint('[AudioEngine] SetFilePath interrupted (attempt $attempt/3). Retrying after 200ms...');
              await Future<void>.delayed(Duration(milliseconds: 200 * attempt));
            } else {
              rethrow;
            }
          }
        }
        debugPrint('[AudioEngine] Asset loaded via FileDescriptor: ${tempFile.path}');
      } else {
        final file = File(path);
        int attempt = 0;
        while (attempt < 3) {
          attempt++;
          try {
            if (await file.exists()) {
              duration = await _player.setFilePath(file.path);
            } else {
              duration = await _player.setAsset(path);
            }
            break;
          } catch (e) {
            if (e.toString().contains('interrupted') && attempt < 3) {
              debugPrint('[AudioEngine] Asset load interrupted (attempt $attempt/3). Retrying after 200ms...');
              await Future<void>.delayed(Duration(milliseconds: 200 * attempt));
            } else {
              rethrow;
            }
          }
        }
      }

      try {
        final session = await AudioSession.instance;
        await session.setActive(true);
      } catch (_) {}

      await _player.setVolume(1.0);
      _currentlyLoadedPath = path;
      debugPrint('[AudioEngine] Asset loaded successfully: $path (Duration: $duration)');
      if (!completer.isCompleted) completer.complete(duration);
      return duration;
    } catch (e) {
      debugPrint('[AudioEngine] Error loading track ($path): $e');
      if (!completer.isCompleted) completer.completeError(e);
      rethrow;
    } finally {
      if (_activeLoadCompleter == completer) {
        _activeLoadCompleter = null;
        _activeLoadPath = null;
      }
    }
  }

  Future<void> play() async {
    await initialize();
    if (_player.processingState == ProcessingState.completed) {
      debugPrint('[AudioEngine] Track completed previously. Seeking to 00:00 before playing.');
      await _player.seek(Duration.zero);
    }

    debugPrint('[AudioEngine] Calling play()');
    _player.play();
    debugPrint('[AudioEngine] Playback started instantly');
  }

  Future<void> pause() async {
    debugPrint('[AudioEngine] Playback paused');
    await _player.pause();
  }

  Future<void> stop() async {
    debugPrint('[AudioEngine] Playback stopped');
    _currentlyLoadedPath = null;
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    debugPrint('[AudioPlayerService] Action: seek($position)');
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    debugPrint('[AudioPlayerService] Action: setVolume($volume)');
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    debugPrint('[AudioPlayerService] Action: setSpeed($speed)');
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  Future<void> setLoopMode(LoopMode mode) async {
    debugPrint('[AudioPlayerService] Action: setLoopMode($mode)');
    await _player.setLoopMode(mode);
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    debugPrint('[AudioPlayerService] Action: setShuffleModeEnabled($enabled)');
    await _player.setShuffleModeEnabled(enabled);
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> dispose() async {
    debugPrint('[AudioPlayerService] Disposing AudioPlayerService.');
    await _player.dispose();
  }
}
