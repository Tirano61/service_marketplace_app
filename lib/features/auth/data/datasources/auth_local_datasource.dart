import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _keyUser = 'cached_user';
  static const _keyToken = 'auth_token';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = user.toJson().toString();
      await _prefs.setString(_keyUser, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = _prefs.getString(_keyUser);
      if (jsonString != null) {
        // Note: In production, use proper JSON parsing
        // This is a simplified implementation
        return null; // Placeholder
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_keyUser);
      await _prefs.remove(_keyToken);
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await _prefs.setString(_keyToken, token);
    } catch (e) {
      throw CacheException('Failed to cache token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return _prefs.getString(_keyToken);
    } catch (e) {
      throw CacheException('Failed to get token');
    }
  }
}
