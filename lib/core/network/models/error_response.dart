import 'package:flutter/foundation.dart';

@immutable
class ErrorResponse {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ErrorResponse({
    required this.code,
    required this.message,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred.',
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
