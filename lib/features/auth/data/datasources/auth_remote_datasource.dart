import 'package:dio/dio.dart';
import 'package:soulsync/core/errors/exceptions.dart';
import 'package:soulsync/core/network/api_endpoints.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/auth/data/models/auth_response_model.dart';
import 'package:soulsync/features/auth/data/models/login_request_model.dart';
import 'package:soulsync/features/auth/data/models/token_model.dart';
import 'package:soulsync/shared/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<TokenModel> refreshToken(String refreshToken);
}

/// Mock Implementation for Sprint 1.3 frontend testing prior to Node.js backend integration.
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String mockAdminEmail = 'admin@soulsync.app';
  static const String mockAdminPassword = 'SoulSync123';

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    // Simulate 1s network roundtrip latency
    await Future<void>.delayed(const Duration(seconds: 1));

    if (request.email.trim().toLowerCase() == mockAdminEmail &&
        request.password == mockAdminPassword) {
      const user = UserModel(
        id: 'usr_soulsync_admin_01',
        email: mockAdminEmail,
        displayName: 'SoulSync Partner',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=SoulSync',
        isOnline: true,
      );

      const tokens = TokenModel(
        accessToken: 'mock_jwt_access_token_soulsync_12345',
        refreshToken: 'mock_jwt_refresh_token_soulsync_67890',
        tokenType: 'Bearer',
        expiresIn: 86400,
      );

      return const AuthResponseModel(user: user, tokens: tokens);
    } else {
      throw const UnauthorizedException(
        message: 'Invalid email address or password. Please try again.',
        statusCode: 401,
      );
    }
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const TokenModel(
      accessToken: 'mock_jwt_access_token_refreshed_99999',
      refreshToken: 'mock_jwt_refresh_token_refreshed_88888',
    );
  }
}

/// Real HTTP Implementation ready for future Node.js backend integration.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  const AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = 'Invalid email or password. Please try again.';
      if (data is Map<String, dynamic>) {
        if (data['message'] is String && (data['message'] as String).isNotEmpty) {
          errorMsg = data['message'] as String;
        } else if (data['errors'] is Map) {
          final errs = data['errors'] as Map;
          if (errs['non_field_errors'] is List && (errs['non_field_errors'] as List).isNotEmpty) {
            errorMsg = errs['non_field_errors'][0].toString();
          }
        }
      }
      throw ServerException(message: errorMsg);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return TokenModel.fromJson(response.data!);
    } catch (e) {
      throw ServerException(message: 'Failed to refresh token: $e');
    }
  }
}
