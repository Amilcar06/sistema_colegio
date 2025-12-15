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
}
