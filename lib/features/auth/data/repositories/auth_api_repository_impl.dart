import 'package:dio/dio.dart';
import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/core/security/auth_token_manager.dart';
import 'package:soulsync/features/auth/domain/entities/auth_token_entity.dart';
import 'package:soulsync/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:soulsync/features/auth/domain/entities/user_entity.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';

class AuthApiRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final AuthTokenManager _tokenManager;

  AuthApiRepositoryImpl({
    required DioClient dioClient,
    required AuthTokenManager tokenManager,
  })  : _dioClient = dioClient,
        _tokenManager = tokenManager;

  @override
  Future<({Failure? failure, UserEntity? user, AuthTokenEntity? tokens})> login(
    LoginCredentialsEntity credentials,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/login/',
        data: {
          'email': credentials.email.trim(),
          'password': credentials.password,
        },
      );

      final payload = response.data;
      if (payload != null && payload['success'] == true) {
        final data = payload['data'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        await _tokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        final userMap = data['user'] as Map<String, dynamic>;
        final userEntity = UserEntity(
          id: userMap['id'] as String? ?? '',
          email: userMap['email'] as String? ?? credentials.email,
          displayName: userMap['displayName'] as String? ??
              userMap['first_name'] as String? ??
              'SoulSync Partner',
          avatarUrl: userMap['avatarUrl'] as String?,
          isOnline: userMap['is_online'] as bool? ?? true,
        );

        final tokenEntity = AuthTokenEntity(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        return (failure: null, user: userEntity, tokens: tokenEntity);
      }

      final errorMsg =
          payload?['message'] as String? ?? 'Invalid login credentials.';
      return (
        failure: AuthFailure(message: errorMsg),
        user: null,
        tokens: null
      );
    } on DioException catch (e) {
      String msg = 'Invalid email or password. Please try again.';
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          msg = data['message'].toString();
        } else if (data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final val = errors.values.first;
            if (val is List && val.isNotEmpty) {
              msg = val.first.toString();
            } else {
              msg = val.toString();
            }
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionError) {
        msg = 'Connection timeout. Please check your internet connection.';
      }
      return (failure: AuthFailure(message: msg), user: null, tokens: null);
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Invalid login credentials. Please try again.'),
        user: null,
        tokens: null,
      );
    }
  }

  @override
  Future<({Failure? failure, UserEntity? user, AuthTokenEntity? tokens})>
      register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? displayName,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/register/',
        data: {
          'email': email.trim(),
          'password': password,
          'password_confirm': password,
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'display_name': (displayName != null && displayName.trim().isNotEmpty)
              ? displayName.trim()
              : '$firstName $lastName'.trim(),
        },
      );

      final payload = response.data;
      if (payload != null && payload['success'] == true) {
        final data = payload['data'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        await _tokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        final userMap = data['user'] as Map<String, dynamic>;
        final userEntity = UserEntity(
          id: userMap['id'] as String? ?? '',
          email: userMap['email'] as String? ?? email,
          displayName:
              userMap['displayName'] as String? ?? displayName ?? firstName,
          avatarUrl: userMap['avatarUrl'] as String?,
          isOnline: true,
        );

        final tokenEntity = AuthTokenEntity(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        return (failure: null, user: userEntity, tokens: tokenEntity);
      }

      final errorMsg = payload?['message'] as String? ?? 'Registration failed.';
      return (
        failure: AuthFailure(message: errorMsg),
        user: null,
        tokens: null
      );
    } on DioException catch (e) {
      String msg = 'Registration server error.';
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] != null) {
          msg = data['message'].toString();
        }
        if (data['errors'] is Map) {
          final errs = data['errors'] as Map;
          if (errs.containsKey('email')) {
            msg = 'Email already exists or is invalid.';
          } else if (errs.isNotEmpty) {
            msg = errs.values.first.toString();
          }
        }
      }
      return (failure: AuthFailure(message: msg), user: null, tokens: null);
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Registration error: $e'),
        user: null,
        tokens: null,
      );
    }
  }

  @override
  Future<Failure?> logout() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _dioClient.post<dynamic>(
          '/auth/logout/',
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
    } finally {
      await _tokenManager.clearTokens();
    }
    return null;
  }

  @override
  Future<({Failure? failure, AuthTokenEntity? tokens})> refreshToken(
    String refreshToken,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/token/refresh/',
        data: {'refreshToken': refreshToken},
      );

      final payload = response.data;
      if (payload != null && payload['success'] == true) {
        final data = payload['data'] as Map<String, dynamic>;
        final newAccess = data['accessToken'] as String;
        final newRefresh = data['refreshToken'] as String? ?? refreshToken;

        await _tokenManager.saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh,
        );

        return (
          failure: null,
          tokens: AuthTokenEntity(
            accessToken: newAccess,
            refreshToken: newRefresh,
          )
        );
      }
      return (
        failure: const AuthFailure(message: 'Token refresh failed.'),
        tokens: null
      );
    } catch (e) {
      return (
        failure: NetworkFailure(message: 'Token refresh failed: $e'),
        tokens: null
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _tokenManager.getAccessToken();
    if (token == null || token.isEmpty) return false;
    return !await _tokenManager.isTokenExpired();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await _tokenManager.getAccessToken();
      if (token == null || token.isEmpty) return null;

      final response = await _dioClient.get<Map<String, dynamic>>('/auth/me/');
      final payload = response.data;
      if (payload != null &&
          payload['success'] == true &&
          payload['data'] != null) {
        final data = payload['data'] as Map<String, dynamic>;
        return UserEntity(
          id: data['id'] as String? ?? '',
          email: data['email'] as String? ?? '',
          displayName: data['displayName'] as String? ??
              data['first_name'] as String? ??
              'SoulSync Partner',
          avatarUrl: data['avatarUrl'] as String?,
          isOnline: data['is_online'] as bool? ?? true,
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenManager.clearTokens();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
