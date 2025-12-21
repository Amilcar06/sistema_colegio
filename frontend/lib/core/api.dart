import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:unidad_educatica_frontend/core/api_config.dart';

final _storage = const FlutterSecureStorage();

final dio = Dio(
  BaseOptions(baseUrl: ApiConfig.baseUrl),
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

