import 'package:flutter/foundation.dart';

/// Centralized logging utility abstraction for SoulSync.
abstract class AppLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] 🎵 SoulSync: $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace:\n$stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] ℹ️ SoulSync: $message');
    }
  }

  static void warning(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('[WARNING] ⚠️ SoulSync: $message');
      if (error != null) debugPrint('Error: $error');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] ❌ SoulSync: $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace:\n$stackTrace');
  }
}
