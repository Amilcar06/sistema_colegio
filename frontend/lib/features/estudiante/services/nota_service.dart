import '../../../core/api.dart';

class NotaService {
  /// Obtener boletín de notas del estudiante por ID
  Future<Map<String, dynamic>> obtenerBoletin(int idEstudiante) async {
    try {
      final response = await dio.get('/notas/boletin/$idEstudiante');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener boletín: $e');
    }
  }

  /// Obtener todas las notas del estudiante
  Future<List<dynamic>> obtenerNotas(int idEstudiante) async {
    try {
      final response = await dio.get('/notas/estudiante/$idEstudiante');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener notas: $e');
    }
  }
}
