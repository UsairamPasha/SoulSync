import 'package:dio/dio.dart';
import 'package:soulsync/core/security/auth_token_manager.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _tokenManager.clearTokens();
    }
    handler.next(err);
  }
}
