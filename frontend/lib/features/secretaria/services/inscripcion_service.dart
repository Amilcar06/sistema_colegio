import 'dart:convert';
import 'package:unidad_educatica_frontend/core/api.dart';

class InscripcionService {
  Future<Map<String, dynamic>> registrarInscripcion(int idEstudiante, int idCurso) async {
    final response = await dio.post('/inscripciones', data: {
      'idEstudiante': idEstudiante,
      'idCurso': idCurso,
    });
    return response.data;
  }

  Future<List<dynamic>> listarPorGestion(int idGestion) async {
    final response = await dio.get('/inscripciones/gestion/$idGestion');
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> listarPorEstudiante(int idEstudiante) async {
    final response = await dio.get('/inscripciones/estudiante/$idEstudiante');
    return response.data as List<dynamic>;
  }
}
