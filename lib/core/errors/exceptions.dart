/// Base exception interface for data layer error handling.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => '$runtimeType: $message (code: $statusCode)';
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class CacheException extends AppException {
  const CacheException({required super.message, super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({required super.message, super.statusCode = 401});
}

class SyncException extends AppException {
  const SyncException({required super.message, super.statusCode});
}
