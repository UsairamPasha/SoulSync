import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/features/auth/domain/entities/auth_token_entity.dart';
import 'package:soulsync/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:soulsync/features/auth/domain/entities/user_entity.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';

/// Use Case for executing user login credentials validation and authentication.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<({Failure? failure, UserEntity? user, AuthTokenEntity? tokens})> call(
    LoginCredentialsEntity credentials,
  ) async {
    return await _repository.login(credentials);
  }
}
