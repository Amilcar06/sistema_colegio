// lib/core/storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'jwt');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt');
  }
}

final defaultTokenStorage = TokenStorage();

Future<void> saveToken(String token) => defaultTokenStorage.saveToken(token);
Future<String?> readToken() => defaultTokenStorage.readToken();
Future<void> deleteToken() => defaultTokenStorage.deleteToken();
