import 'package:dio/dio.dart';

enum ApiExceptionType {
  unauthorized,
  forbidden,
  notFound,
  timeout,
  offline,
  serverError,
  validation,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    required this.type,
    this.details,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'No internet connection. Trying to reconnect...',
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Trying to reconnect...',
          type: ApiExceptionType.offline,
        );

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String msg = 'Unable to contact SoulSync server. Please try again.';
        if (data is Map<String, dynamic> && data['message'] != null) {
          msg = data['message'].toString();
        }

        if (status == 401) {
          return ApiException(
            message:
                msg.isNotEmpty ? msg : 'Session expired. Please log in again.',
            statusCode: status,
            type: ApiExceptionType.unauthorized,
            details: data,
          );
        } else if (status == 403) {
          return ApiException(
            message: msg.isNotEmpty ? msg : 'Access forbidden.',
            statusCode: status,
            type: ApiExceptionType.forbidden,
            details: data,
          );
        } else if (status == 404) {
          return ApiException(
            message: msg.isNotEmpty ? msg : 'Resource not found.',
            statusCode: status,
            type: ApiExceptionType.notFound,
            details: data,
          );
        } else if (status == 422) {
          return ApiException(
            message: msg.isNotEmpty ? msg : 'Validation failed.',
            statusCode: status,
            type: ApiExceptionType.validation,
            details: data,
          );
        } else if (status != null && status >= 500) {
          return ApiException(
            message: 'Server error ($status). Please try again later.',
            statusCode: status,
            type: ApiExceptionType.serverError,
            details: data,
          );
        }

        return ApiException(
          message: msg,
          statusCode: status,
          type: ApiExceptionType.unknown,
          details: data,
        );

      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          type: ApiExceptionType.unknown,
        );
    }
  }

  @override
  String toString() => 'ApiException($type, $statusCode): $message';
}
