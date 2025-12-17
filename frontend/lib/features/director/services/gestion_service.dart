import 'package:dio/dio.dart';
import '../../../core/api_config.dart';
import '../../../core/storage.dart';

class Gestion {
  final int idGestion;
  final int anio;
  final bool activa;

  Gestion({required this.idGestion, required this.anio, required this.activa});

  factory Gestion.fromJson(Map<String, dynamic> json) {
    return Gestion(
      idGestion: json['idGestion'] ?? 0,
      anio: json['anio'] ?? 0,
      // El backend devuelve 'estado', mapeamos a 'activa'
      activa: json['estado'] ?? false, 
    );
  }
}

class GestionService {
  final Dio _dio = Dio();
  final String _baseUrl = '${ApiConfig.baseUrl}/api/gestion';

  Future<List<Gestion>> getAll() async {
    try {
      final token = await readToken();
      final response = await _dio.get(
        _baseUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      return (response.data as List)
          .map((e) => Gestion.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar gestiones: $e');
    }
  }

  Future<void> create() async {
    try {
      final token = await readToken();
      await _dio.post(
        _baseUrl,
        data: {'estado': true},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e, 'crear gestión');
    }
  }

  Future<void> update(int id, int anio, bool nuevoEstado) async {
    try {
      final token = await readToken();
      await _dio.put(
        '$_baseUrl/$id',
        data: {'anio': anio, 'estado': nuevoEstado},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e, 'actualizar gestión');
    }
  }

  Future<void> delete(int id) async {
    try {
      final token = await readToken();
      await _dio.delete(
        '$_baseUrl/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e, 'eliminar gestión');
    }
  }

  Exception _handleError(dynamic e, String action) {
    if (e is DioException) {
      final msg = e.response?.data['message'] ?? e.response?.data['error'] ?? e.message;
      if (e.response?.statusCode == 400) {
        return Exception('No se pudo $action: $msg');
      } else if (e.response?.statusCode == 500 && msg.toString().contains('ConstraintViolation')) {
        return Exception('No se puede eliminar la gestión porque tiene datos asociados (inscripciones, notas, etc).');
      }
      return Exception('Error al $action: $msg');
    }
    return Exception('Error inesperado al $action: $e');
  }
}
