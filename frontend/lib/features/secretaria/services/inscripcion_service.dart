import 'dart:convert';
import 'package:unidad_educatica_frontend/core/api.dart';
import 'package:unidad_educatica_frontend/shared/models/page_response.dart';
import '../models/inscripcion_response.dart';

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

  Future<PageResponse<InscripcionResponseDTO>> listarPorGestionPaginated(int idGestion, {int page = 0, int size = 20}) async {
    final response = await dio.get('/inscripciones/gestion/$idGestion', queryParameters: {'page': page, 'size': size});
    return PageResponse<InscripcionResponseDTO>.fromJson(
      response.data, 
      (json) => InscripcionResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<dynamic>> listarPorEstudiante(int idEstudiante) async {
    final response = await dio.get('/inscripciones/estudiante/$idEstudiante');
    return response.data as List<dynamic>;
  }
}
