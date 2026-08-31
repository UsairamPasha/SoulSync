import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/features/auth/domain/entities/auth_token_entity.dart';
import 'package:soulsync/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:soulsync/features/auth/domain/entities/user_entity.dart';

/// Abstract Domain Repository interface for Authentication operations.
abstract class AuthRepository {
  Future<({Failure? failure, UserEntity? user, AuthTokenEntity? tokens})> login(
    LoginCredentialsEntity credentials,
  );

  Future<({Failure? failure, UserEntity? user, AuthTokenEntity? tokens})>
      register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? displayName,
  });

  Future<Failure?> logout();

  Future<({Failure? failure, AuthTokenEntity? tokens})> refreshToken(
    String refreshToken,
  );

  Future<bool> isLoggedIn();

  Future<UserEntity?> getCurrentUser();
}
