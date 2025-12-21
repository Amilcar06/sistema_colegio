import 'package:unidad_educatica_frontend/core/api.dart';

class HorarioService {
  // Crear horario
  Future<void> crearHorario(Map<String, dynamic> data) async {
    await dio.post('/horarios', data: data);
  }

  // Actualizar horario
  Future<void> updateHorario(int id, Map<String, dynamic> data) async {
    await dio.put('/horarios/$id', data: data);
  }

  // Eliminar horario
  Future<void> eliminarHorario(int id) async {
    await dio.delete('/horarios/$id');
  }

  // Listar por curso
  Future<List<dynamic>> listarPorCurso(int idCurso) async {
    final response = await dio.get('/horarios/curso/$idCurso');
    return response.data as List<dynamic>;
  }

  // Listar por profesor
  Future<List<dynamic>> listarPorProfesor(int idProfesor) async {
    final response = await dio.get('/horarios/profesor/$idProfesor');
    return response.data as List<dynamic>;
  }
}
