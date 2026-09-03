/// Network and API constants for SoulSync.
abstract class ApiConstants {
  static const String baseUrl =
      'https://finite-handheld-sugar-objective.trycloudflare.com/api/v1'; // Configurable for dev/prod
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String jsonContentType = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
}
