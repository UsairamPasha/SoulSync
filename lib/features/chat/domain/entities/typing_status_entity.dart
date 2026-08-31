import 'package:flutter/foundation.dart';

@immutable
class TypingStatusEntity {
  final String userId;
  final bool isTyping;
  final DateTime updatedAt;

  const TypingStatusEntity({
    required this.userId,
    this.isTyping = false,
    required this.updatedAt,
  });
}
