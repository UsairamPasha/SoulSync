import 'package:flutter/foundation.dart';

@immutable
class InviteEntity {
  final String code;
  final String roomId;
  final DateTime expiresAt;
  final bool isUsed;

  const InviteEntity({
    required this.code,
    required this.roomId,
    required this.expiresAt,
    this.isUsed = false,
  });
}
