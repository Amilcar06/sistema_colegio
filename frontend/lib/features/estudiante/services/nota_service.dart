import '../../../core/api.dart';

class NotaService {
  /// Obtener boletín de notas del estudiante por ID (con opción de gestión)
  Future<Map<String, dynamic>> obtenerBoletin(int idEstudiante, {int? idGestion}) async {
    try {
      final query = idGestion != null ? {'gestion': idGestion} : null;
      final response = await dio.get('/notas/boletin/$idEstudiante', queryParameters: query);
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
