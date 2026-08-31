import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/config/app_config.dart';
import 'package:soulsync/core/network/interceptors/auth_interceptor.dart';
import 'package:soulsync/core/network/interceptors/retry_interceptor.dart';
import 'package:soulsync/core/security/auth_token_manager.dart';

class DioClient {
  final Dio _dio;
  final AppConfig config;
  final AuthTokenManager tokenManager;

  DioClient({
    required this.config,
    required this.tokenManager,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'ngrok-skip-browser-warning': '69420',
              'User-Agent': 'SoulSyncApp/1.0',
            },
          ),
        ) {
    _initInterceptors();
  }

  Dio get dio => _dio;

  void _initInterceptors() {
    _dio.interceptors.add(AuthInterceptor(tokenManager));
    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    if (config.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

final authTokenManagerProvider = Provider<AuthTokenManager>((ref) {
  return AuthTokenManager();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenManager = ref.watch(authTokenManagerProvider);
  return DioClient(config: config, tokenManager: tokenManager);
});
