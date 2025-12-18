import 'package:dio/dio.dart';
import '../../../core/api.dart';
import '../models/institucion.dart';

class InstitucionService {
  
  Future<Institucion> obtenerDatos() async {
    try {
      final response = await dio.get('/institucion');
      return Institucion.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al cargar datos de institución: $e');
    }
  }

  Future<Institucion> actualizarDatos(Institucion institucion) async {
    try {
      final response = await dio.put(
        '/institucion',
        data: institucion.toJson(),
      );
      return Institucion.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar institución: $e');
    }
  }
}
