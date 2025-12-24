import 'package:dio/dio.dart';
import '../../../core/api.dart';
import '../models/estado_cuenta.dart';

class FinanzasService {
  final Dio _dio = dio; // Use global interceptor-configured dio instance

  Future<EstadoCuenta> getEstadoCuenta(int idEstudiante) async {
    try {
      final response = await _dio.get('/finanzas/estado-cuentas/$idEstudiante');
      return EstadoCuenta.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener estado de cuenta: $e');
    }
  }
  
  // Future methods for creating dynamic concepts...
}
