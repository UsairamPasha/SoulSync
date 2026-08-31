import 'package:flutter/foundation.dart';
import 'package:soulsync/features/auth/domain/entities/auth_token_entity.dart';

@immutable
class TokenModel extends AuthTokenEntity {
  const TokenModel({
    required super.accessToken,
    required super.refreshToken,
    super.tokenType = 'Bearer',
    super.expiresIn = 86400,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int? ?? 86400,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
    };
  }
}
