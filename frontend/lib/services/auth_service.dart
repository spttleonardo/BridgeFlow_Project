import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Retorna Future<bool> para checagem assíncrona
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
