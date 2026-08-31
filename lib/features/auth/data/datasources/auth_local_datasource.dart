import 'dart:convert';
import 'package:soulsync/core/constants/storage_keys.dart';
import 'package:soulsync/core/storage/secure_storage_service.dart';
import 'package:soulsync/shared/models/user_model.dart';
import 'package:soulsync/features/auth/data/models/token_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(TokenModel tokens);
  Future<TokenModel?> getTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;

  const AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveTokens(TokenModel tokens) async {
    await _secureStorage.write(
        key: StorageKeys.authToken, value: tokens.accessToken);
    await _secureStorage.write(
        key: StorageKeys.refreshToken, value: tokens.refreshToken);
  }

  @override
  Future<TokenModel?> getTokens() async {
    final accessToken = await _secureStorage.read(key: StorageKeys.authToken);
    final refreshToken =
        await _secureStorage.read(key: StorageKeys.refreshToken);
    if (accessToken != null && refreshToken != null) {
      return TokenModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    return null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _secureStorage.write(key: StorageKeys.userId, value: user.id);
    await _secureStorage.write(
        key: StorageKeys.userPreferences, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson =
        await _secureStorage.read(key: StorageKeys.userPreferences);
    if (userJson != null) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.userPreferences);
  }
}
