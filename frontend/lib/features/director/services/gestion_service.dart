import 'package:dio/dio.dart';
import 'package:unidad_educatica_frontend/core/api.dart';

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
  Future<List<Gestion>> getAll() async {
    try {
      final response = await dio.get('/gestion');
      
      return (response.data as List)
          .map((e) => Gestion.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar gestiones: $e');
    }
  }

  Future<void> create() async {
    try {
      await dio.post('/gestion', data: {'estado': true});
    } catch (e) {
      throw _handleError(e, 'crear gestión');
    }
  }

  Future<void> update(int id, int anio, bool nuevoEstado) async {
    try {
      await dio.put('/gestion/$id', data: {'anio': anio, 'estado': nuevoEstado});
    } catch (e) {
      throw _handleError(e, 'actualizar gestión');
    }
  }

  Future<void> delete(int id) async {
    try {
      await dio.delete('/gestion/$id');
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
