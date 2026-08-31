import 'package:soulsync/core/errors/failures.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';

/// Use Case for logging out the active user and clearing session tokens.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<Failure?> call() async {
    return await _repository.logout();
  }
}
