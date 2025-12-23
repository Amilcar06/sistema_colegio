// lib/state/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../core/storage.dart';

class AuthProvider with ChangeNotifier {
  final TokenStorage _storage;

  AuthProvider({TokenStorage? storage}) : _storage = storage ?? defaultTokenStorage;

  String? _token;
  String? _rol;

  String? get token => _token;
  String? get rol => _rol;

  bool get isAuthenticated => _token != null;

  Future<void> login(String token, String rol) async {
    _token = token;
    _rol = rol;
    await _storage.saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _rol = null;
    await _storage.deleteToken();
    notifyListeners();
  }

  Future<void> checkAuthOnStart() async {
    final storedToken = await _storage.readToken();
    if (storedToken != null) {
      if (JwtDecoder.isExpired(storedToken)) {
        await logout();
      } else {
        _token = storedToken;
        final decodedToken = JwtDecoder.decode(storedToken);
        // The backend uses key "role" for the role name
        _rol = decodedToken['role'] as String?;
      }
    }
    notifyListeners();
  }
}
