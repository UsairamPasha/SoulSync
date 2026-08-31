import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/features/auth/domain/entities/auth_token_entity.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';

/// Use Case for refreshing expired JWT access tokens.
class RefreshTokenUseCase {
  final AuthRepository _repository;

  const RefreshTokenUseCase(this._repository);

  Future<({Failure? failure, AuthTokenEntity? tokens})> call(
      String refreshToken) async {
    return await _repository.refreshToken(refreshToken);
  }
}
