import 'package:flutter/foundation.dart';

/// Domain entity representing an authenticated SoulSync user.
@immutable
class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
