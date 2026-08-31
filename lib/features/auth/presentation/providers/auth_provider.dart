import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/features/auth/data/repositories/auth_api_repository_impl.dart';
import 'package:soulsync/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:soulsync/features/auth/domain/entities/user_entity.dart';
import 'package:soulsync/features/auth/domain/repositories/auth_repository.dart';
import 'package:soulsync/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:soulsync/features/auth/domain/usecases/login_usecase.dart';
import 'package:soulsync/features/auth/domain/usecases/logout_usecase.dart';
import 'package:soulsync/features/auth/domain/usecases/refresh_token_usecase.dart';

/// Enum representing authentication status.
enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

/// Immutable state holding authentication status, current user, and error messages.
@immutable
class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.authenticating() =>
      const AuthState(status: AuthStatus.authenticating);
  factory AuthState.authenticated(UserEntity user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// AuthNotifier managing global authentication state using Riverpod.
class AuthNotifier extends StateNotifier<AuthState> {
  final CheckAuthUseCase _checkAuthUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required CheckAuthUseCase checkAuthUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _checkAuthUseCase = checkAuthUseCase,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthState.initial());

  Future<void> checkAuthStatus() async {
    state = AuthState.authenticating();
    final user = await _checkAuthUseCase();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    state = AuthState.authenticating();

    final result = await _loginUseCase(
      LoginCredentialsEntity(
        email: email,
        password: password,
        rememberMe: rememberMe,
      ),
    );

    if (result.failure != null) {
      state = AuthState.error(result.failure!.message);
      return false;
    } else if (result.user != null) {
      state = AuthState.authenticated(result.user!);
      return true;
    } else {
      state = AuthState.error('Unknown login failure');
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState.authenticating();
    await _logoutUseCase();
    state = AuthState.unauthenticated();
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, errorMessage: null);
    }
  }
}

// Data Layer Provider - Switch to Real Django API Repository Implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final tokenManager = ref.watch(authTokenManagerProvider);
  return AuthApiRepositoryImpl(
      dioClient: dioClient, tokenManager: tokenManager);
});

// Domain Use Case Providers
final checkAuthUseCaseProvider = Provider<CheckAuthUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthUseCase(repository);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repository);
});

// Presentation AuthNotifier Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    checkAuthUseCase: ref.watch(checkAuthUseCaseProvider),
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});
