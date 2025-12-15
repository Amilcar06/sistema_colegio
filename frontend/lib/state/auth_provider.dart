// lib/state/auth_provider.dart
import 'package:flutter/material.dart';
import '../core/storage.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _rol;

  String? get token => _token;
  String? get rol => _rol;

  bool get isAuthenticated => _token != null;

  Future<void> login(String token, String rol) async {
    _token = token;
    _rol = rol;
    await saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _rol = null;
    await deleteToken();
    notifyListeners();
  }

  Future<void> checkAuthOnStart() async {
    final storedToken = await readToken();
    if (storedToken != null) {
      _token = storedToken;
      // Puedes decodificar el JWT para sacar el rol
      // o hacer un endpoint tipo `/auth/me`
    }
    notifyListeners();
  }
}
