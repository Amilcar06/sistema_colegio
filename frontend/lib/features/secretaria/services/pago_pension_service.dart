import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../../../../core/api.dart';
import '../../../../core/api.dart';
import 'package:unidad_educatica_frontend/core/api_config.dart';
import 'package:unidad_educatica_frontend/core/services/auth_service.dart';

class PagoPensionService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  PagoPensionService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<dynamic>> getDeudasEstudiante(int idEstudiante) async {
    final response = await _dio.get('/api/finanzas/pagos/estudiante/$idEstudiante');
    return response.data;
  }

  Future<Map<String, dynamic>> registrarPago(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/finanzas/pagos', data: data);
    return response.data;
  }

  Future<List<dynamic>> getPagos({int? idEstudiante}) async {
    final response = await _dio.get('/api/finanzas/pagos', queryParameters: {
      if (idEstudiante != null) 'idEstudiante': idEstudiante,
    });
    return response.data;
  }
  // Descargar Recibo
  Future<Uint8List> descargarRecibo(int idPago) async {
    final response = await dio.get(
      '/reportes/recibo/$idPago',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
}
