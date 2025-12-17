import 'package:dio/dio.dart';
import '../../../../core/api.dart'; // Import global Dio client
import '../models/curso.dart';
import '../models/grado.dart';

class CursoService {
  final Dio _dio = dio;

  Future<List<Curso>> listarCursos([int? gestion]) async {
    try {
      final response = await _dio.get('/cursos', queryParameters: gestion != null ? {'gestion': gestion} : null);
      final List data = response.data;
      return data.map((e) => Curso.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al listar cursos: $e');
    }
  }

  Future<List<Grado>> listarGrados() async {
    try {
      final response = await _dio.get('/grados');
      final List data = response.data;
      return data.map((e) => Grado.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al listar grados: $e');
    }
  }

  Future<void> crearCurso(int idGrado, String paralelo, String turno) async {
    try {
      await _dio.post('/cursos', data: {
        'idGrado': idGrado,
        'paralelo': paralelo,
        'turno': turno
      });
    } catch (e) {
      throw Exception('Error al crear curso: $e');
    }
  }

  Future<void> updateCurso(int id, int idGrado, String paralelo, String turno) async {
    try {
      await _dio.put('/cursos/$id', data: {
        'idGrado': idGrado,
        'paralelo': paralelo,
        'turno': turno
      });
    } catch (e) {
      throw Exception('Error al actualizar curso: $e');
    }
  }

  Future<void> eliminarCurso(int id) async {
    try {
      await _dio.delete('/cursos/$id');
    } catch (e) {
      throw Exception('Error al eliminar curso: $e');
    }
  }
}
