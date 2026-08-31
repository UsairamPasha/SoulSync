import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenManager {
  static const _keyAccessToken = 'soulsync_access_token';
  static const _keyRefreshToken = 'soulsync_refresh_token';
  static const _keyTokenExpiry = 'soulsync_token_expiry';

  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyAccessToken);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyRefreshToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
      if (expiresAt != null) {
        await prefs.setInt(_keyTokenExpiry, expiresAt.millisecondsSinceEpoch);
      }
    } catch (_) {}
  }

  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyTokenExpiry);
    } catch (_) {}
  }

  Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryMs = prefs.getInt(_keyTokenExpiry);
      if (expiryMs == null) return false;
      return DateTime.now().millisecondsSinceEpoch >= expiryMs;
    } catch (_) {
      return false;
    }
  }
}
