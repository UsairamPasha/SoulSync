import 'package:flutter/foundation.dart';
import 'package:soulsync/shared/models/user_model.dart';
import 'package:soulsync/features/auth/data/models/token_model.dart';

@immutable
class AuthResponseModel {
  final UserModel user;
  final TokenModel tokens;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenModel.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}
