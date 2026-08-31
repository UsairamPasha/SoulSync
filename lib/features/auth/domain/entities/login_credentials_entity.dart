import 'package:flutter/foundation.dart';

/// Domain entity representing user login input parameters.
@immutable
class LoginCredentialsEntity {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginCredentialsEntity({
    required this.email,
    required this.password,
    this.rememberMe = true,
  });
}
