import '../../../core/api.dart';

class PagoService {
  /// Listar deudas/pagos del estudiante
  Future<List<dynamic>> listarDeudas(int idEstudiante) async {
    try {
      final response = await dio.get('/finanzas/pagos/estudiante/$idEstudiante');
      return response.data;
    } catch (e) {
      throw Exception('Error al listar pagos: $e');
    }
  }
  /// Registrar un pago
  Future<Map<String, dynamic>> registrarPago({
    required int idCuentaCobrar,
    required double monto,
    required String metodoPago, // 'EFECTIVO', 'QR', 'TRANSFERENCIA'
    String? observaciones,
  }) async {
    try {
      final response = await dio.post('/finanzas/pagos', data: {
        'idCuentaCobrar': idCuentaCobrar,
        'montoPagado': monto,
        'metodoPago': metodoPago,
        'observaciones': observaciones,
      });
      return response.data;
    } catch (e) {
      throw Exception('Error al registrar pago: $e');
    }
  }

  /// Listar historial de pagos (general o por estudiante)
  Future<List<dynamic>> listarPagos({int? idEstudiante}) async {
    try {
      final query = idEstudiante != null ? {'idEstudiante': idEstudiante} : null;
      final response = await dio.get('/finanzas/pagos', queryParameters: query);
      return response.data;
    } catch (e) {
      throw Exception('Error al listar historial de pagos: $e');
    }
  }
}
