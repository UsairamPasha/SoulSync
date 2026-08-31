import 'package:soulsync/features/auth/domain/entities/user_entity.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';

/// Use Case for checking active authentication session status on application startup.
class CheckAuthUseCase {
  final AuthRepository _repository;

  const CheckAuthUseCase(this._repository);

  Future<UserEntity?> call() async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      return await _repository.getCurrentUser();
    }
    return null;
  }
}
