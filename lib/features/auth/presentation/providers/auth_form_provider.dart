import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class LoginFormState {
  final String email;
  final String password;
  final bool rememberMe;
  final bool isSubmitting;
  final String? emailError;
  final String? passwordError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.rememberMe = true,
    this.isSubmitting = false,
    this.emailError,
    this.passwordError,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? isSubmitting,
    String? emailError,
    String? passwordError,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailError: emailError,
      passwordError: passwordError,
    );
  }
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  bool validateForm() {
    String? emailErr;
    String? passwordErr;

    if (state.email.trim().isEmpty) {
      emailErr = 'Email address is required';
    } else {
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(state.email.trim())) {
        emailErr = 'Please enter a valid email address';
      }
    }

    if (state.password.isEmpty) {
      passwordErr = 'Password is required';
    } else if (state.password.length < 8) {
      passwordErr = 'Password must be at least 8 characters';
    }

    state = state.copyWith(emailError: emailErr, passwordError: passwordErr);
    return emailErr == null && passwordErr == null;
  }
}

final loginFormNotifierProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  return LoginFormNotifier();
});
