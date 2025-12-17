import 'package:dio/dio.dart';
import '../../../../core/api.dart';
import '../models/materia.dart';

class MateriaService {
  final Dio _dio = dio;

  Future<List<Materia>> listarMaterias() async {
    try {
      final response = await _dio.get('/materias');
      final List data = response.data;
      return data.map((e) => Materia.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al listar materias: $e');
    }
  }

  Future<void> crearMateria(String nombre) async {
    try {
      await _dio.post('/materias', data: {'nombre': nombre});
    } catch (e) {
      throw Exception('Error al crear materia: $e');
    }
  }

  Future<void> updateMateria(int id, String nombre) async {
    try {
      await _dio.put('/materias/$id', data: {'nombre': nombre});
    } catch (e) {
      throw Exception('Error al actualizar materia: $e');
    }
  }

  Future<void> eliminarMateria(int id) async {
    try {
      await _dio.delete('/materias/$id');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 500) {
         // Check for foreign key constraint violation message if possible
         throw Exception('No se puede eliminar: Materia en uso.');
      }
      throw Exception('Error al eliminar materia: $e');
    }
  }
}
