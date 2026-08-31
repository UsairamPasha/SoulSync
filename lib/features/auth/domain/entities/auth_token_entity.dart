import 'package:flutter/foundation.dart';

/// Domain entity representing JWT authentication tokens.
@immutable
class AuthTokenEntity {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const AuthTokenEntity({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 86400, // 24 hours
  });
}
