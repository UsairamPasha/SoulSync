import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';

enum RegisterStatus { initial, loading, success, error }

class RegisterState {
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  final AuthRepository _repository;
  final AuthNotifier _authNotifier;

  RegisterNotifier(this._repository, this._authNotifier)
      : super(const RegisterState());

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? displayName,
  }) async {
    state = state.copyWith(status: RegisterStatus.loading, errorMessage: null);

    final result = await _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
    );

    if (result.failure != null) {
      state = state.copyWith(
        status: RegisterStatus.error,
        errorMessage: result.failure!.message,
      );
      return false;
    } else if (result.user != null) {
      state = state.copyWith(status: RegisterStatus.success);
      _authNotifier.state = AuthState.authenticated(result.user!);
      return true;
    } else {
      state = state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }
}

final registerNotifierProvider =
    StateNotifierProvider.autoDispose<RegisterNotifier, RegisterState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  return RegisterNotifier(repository, authNotifier);
});
