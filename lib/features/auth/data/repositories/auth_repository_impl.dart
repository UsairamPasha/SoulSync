import 'package:soulsync/core/errors/exceptions.dart';
import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:soulsync/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:soulsync/features/auth/data/models/login_request_model.dart';
import 'package:soulsync/features/auth/domain/entities/auth_token_entity.dart';
import 'package:soulsync/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:soulsync/features/auth/domain/entities/user_entity.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<({Failure? failure, UserEntity? user, AuthTokenEntity? tokens})> login(
    LoginCredentialsEntity credentials,
  ) async {
    try {
      final request = LoginRequestModel(
        email: credentials.email,
        password: credentials.password,
        rememberMe: credentials.rememberMe,
      );

      final authResponse = await _remoteDataSource.login(request);

      if (credentials.rememberMe) {
        await _localDataSource.saveTokens(authResponse.tokens);
        await _localDataSource.saveUser(authResponse.user);
      }

      final userEntity = UserEntity(
        id: authResponse.user.id,
        email: authResponse.user.email,
        displayName: authResponse.user.displayName,
        avatarUrl: authResponse.user.avatarUrl,
        isOnline: authResponse.user.isOnline,
      );

      return (failure: null, user: userEntity, tokens: authResponse.tokens);
    } on UnauthorizedException catch (e) {
      return (
        failure: AuthFailure(message: e.message, code: '401'),
        user: null,
        tokens: null,
      );
    } on ServerException catch (e) {
      return (
        failure: ServerFailure(message: e.message),
        user: null,
        tokens: null,
      );
    } catch (e) {
      return (
        failure: UnknownFailure(message: 'Unexpected authentication error: $e'),
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
    // Delegates to login mock for local testing if needed
    final credentials =
        LoginCredentialsEntity(email: email, password: password);
    return login(credentials);
  }

  @override
  Future<Failure?> logout() async {
    try {
      await _localDataSource.clearAuthData();
      return null;
    } catch (e) {
      return UnknownFailure(message: 'Error during logout: $e');
    }
  }

  @override
  Future<({Failure? failure, AuthTokenEntity? tokens})> refreshToken(
    String refreshToken,
  ) async {
    try {
      final tokens = await _remoteDataSource.refreshToken(refreshToken);
      await _localDataSource.saveTokens(tokens);
      return (failure: null, tokens: tokens);
    } on AppException catch (e) {
      return (failure: AuthFailure(message: e.message), tokens: null);
    } catch (e) {
      return (failure: UnknownFailure(message: e.toString()), tokens: null);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final tokens = await _localDataSource.getTokens();
    return tokens != null && tokens.accessToken.isNotEmpty;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = await _localDataSource.getUser();
    if (userModel != null) {
      return UserEntity(
        id: userModel.id,
        email: userModel.email,
        displayName: userModel.displayName,
        avatarUrl: userModel.avatarUrl,
        isOnline: userModel.isOnline,
      );
    }
    return null;
  }
}
