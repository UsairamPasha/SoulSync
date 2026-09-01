import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service wrapping FlutterSecureStorage for encrypted local persistence with web fallback.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } else {
        rethrow;
      }
    }
  }

  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      }
      return null;
    }
  }

  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      }
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    }
  }
}

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'soulsync_secure_db',
      publicKey: 'soulsync_public_key',
    ),
  );
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageService(storage);
});
