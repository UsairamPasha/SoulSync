import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulsync/core/constants/storage_keys.dart';

class ServerUrlStorageService {
  Future<String?> getSavedServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(StorageKeys.customServerUrl);
      if (url != null && url.trim().isNotEmpty) {
        return cleanUrl(url);
      }
    } catch (e) {
      debugPrint('[ServerUrlStorage] Error loading server URL: $e');
    }
    return null;
  }

  Future<bool> saveServerUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = cleanUrl(url);
      return await prefs.setString(StorageKeys.customServerUrl, clean);
    } catch (e) {
      debugPrint('[ServerUrlStorage] Error saving server URL: $e');
      return false;
    }
  }

  Future<bool> clearServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(StorageKeys.customServerUrl);
    } catch (e) {
      debugPrint('[ServerUrlStorage] Error clearing server URL: $e');
      return false;
    }
  }

  static String cleanUrl(String raw) {
    var trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('/api/v1')) {
      trimmed = trimmed.substring(0, trimmed.length - 7);
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }
}
