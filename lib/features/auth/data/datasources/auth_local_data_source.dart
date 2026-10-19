import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyAccessToken = 'shopsphere_access_token';
  static const String _keyRefreshToken = 'shopsphere_refresh_token';
  static const String _keyCachedUser = 'shopsphere_cached_user';

  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  const AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: _keyAccessToken, value: accessToken);
    await secureStorage.write(key: _keyRefreshToken, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() {
    return secureStorage.read(key: _keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() {
    return secureStorage.read(key: _keyRefreshToken);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      _keyCachedUser,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(_keyCachedUser);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await secureStorage.delete(key: _keyAccessToken);
    await secureStorage.delete(key: _keyRefreshToken);
    await sharedPreferences.remove(_keyCachedUser);
  }
}
