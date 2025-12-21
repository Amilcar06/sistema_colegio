import 'package:unidad_educatica_frontend/core/api.dart';
import '../models/asignacion_docente.dart';

class AsignacionService {
  Future<List<AsignacionDocente>> listarPorCurso(int idCurso) async {
    final response = await dio.get('/asignaciones/curso/$idCurso');

    if (response.statusCode == 200) {
      final List<dynamic> body = response.data;
      return body.map((e) => AsignacionDocente.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar asignaciones');
    }
  }

  Future<void> crearAsignacion(int idCurso, int idMateria, int idProfesor, int gestionId) async {
    final body = {
      'idCurso': idCurso,
      'idMateria': idMateria,
      'idProfesor': idProfesor,
      'idGestion': gestionId,
    };

    final response = await dio.post('/asignaciones', data: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear asignación');
    }
  }

  Future<void> actualizarAsignacion(int idAsignacion, int idCurso, int idMateria, int idProfesor, int gestionId) async {
    final body = {
      'idCurso': idCurso,
      'idMateria': idMateria,
      'idProfesor': idProfesor,
      'idGestion': gestionId,
    };

    final response = await dio.put('/asignaciones/$idAsignacion', data: body);

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar asignación');
    }
  }

  Future<void> eliminarAsignacion(int idAsignacion) async {
    final response = await dio.delete('/asignaciones/$idAsignacion');

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar asignación');
    }
  }
}
