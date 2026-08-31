import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Key-value local storage interface.
abstract class StorageService {
  Future<void> init();
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

class StorageServiceImpl implements StorageService {
  final Map<String, String> _memoryCache = {};

  @override
  Future<void> init() async {}

  @override
  Future<String?> getString(String key) async {
    return _memoryCache[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _memoryCache[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
  }

  @override
  Future<void> clear() async {
    _memoryCache.clear();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageServiceImpl();
});
