import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = const FlutterSecureStorage();

final dio = Dio(
  BaseOptions(baseUrl: 'http://localhost:8080/api'), // Cambiar a 10.0.2.2 para Android Emulator
)..interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _storage.read(key: 'jwt');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ),
);

