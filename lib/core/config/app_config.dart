import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/config/environment.dart';
import 'package:soulsync/core/storage/server_url_storage_service.dart';

class AppConfig {
  final AppEnvironment environment;
  final String baseUrl;
  final String apiVersion;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool useApiRepositories;
  final bool enableLogging;

  const AppConfig({
    this.environment = AppEnvironment.dev,
    this.baseUrl =
        'https://achievements-popular-maximize-track.trycloudflare.com',
    this.apiVersion = 'v1',
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
    this.useApiRepositories = true,
    this.enableLogging = true,
  });

  String get apiBaseUrl => '$baseUrl/api/$apiVersion';

  AppConfig copyWith({
    AppEnvironment? environment,
    String? baseUrl,
    String? apiVersion,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? useApiRepositories,
    bool? enableLogging,
  }) {
    return AppConfig(
      environment: environment ?? this.environment,
      baseUrl: baseUrl ?? this.baseUrl,
      apiVersion: apiVersion ?? this.apiVersion,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      useApiRepositories: useApiRepositories ?? this.useApiRepositories,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}

class ServerUrlNotifier extends StateNotifier<String> {
  final ServerUrlStorageService _storageService;
  static const String defaultUrl =
      'https://achievements-popular-maximize-track.trycloudflare.com';

  ServerUrlNotifier(this._storageService) : super(defaultUrl) {
    _init();
  }

  Future<void> _init() async {
    final saved = await _storageService.getSavedServerUrl();
    if (saved != null && saved.isNotEmpty) {
      if (saved.contains('trycloudflare.com') && saved != defaultUrl) {
        await _storageService.clearServerUrl();
        state = defaultUrl;
      } else {
        state = saved;
      }
    }
  }

  Future<bool> updateUrl(String newUrl) async {
    final clean = ServerUrlStorageService.cleanUrl(newUrl);
    final success = await _storageService.saveServerUrl(clean);
    if (success) {
      state = clean;
    }
    return success;
  }

  Future<bool> resetToDefault() async {
    await _storageService.clearServerUrl();
    state = defaultUrl;
    return true;
  }
}

final serverUrlStorageServiceProvider =
    Provider<ServerUrlStorageService>((ref) {
  return ServerUrlStorageService();
});

final activeServerUrlNotifierProvider =
    StateNotifierProvider<ServerUrlNotifier, String>((ref) {
  final storage = ref.watch(serverUrlStorageServiceProvider);
  return ServerUrlNotifier(storage);
});

final appConfigProvider = Provider<AppConfig>((ref) {
  final activeUrl = ref.watch(activeServerUrlNotifierProvider);
  return AppConfig(baseUrl: activeUrl);
});
