import 'package:dio/dio.dart';
import '../../../../core/api.dart';
import '../models/configuracion_paralelo.dart';
import '../../../core/services/auth_service.dart';

class ConfiguracionParaleloService {
  Future<List<ConfiguracionParalelo>> listar() async {
    try {
      final response = await dio.get('/configuracion/paralelos');
      return (response.data as List)
          .map((e) => ConfiguracionParalelo.fromJson(e))
          .toList();
    } catch (e) {
      print('Error listar paralelos: $e');
      throw Exception('Error al cargar configuración de paralelos');
    }
  }

  Future<ConfiguracionParalelo> toggleEstado(int id, bool nuevoEstado) async {
    try {
      final response = await dio.patch('/configuracion/paralelos/$id', data: {
        'activo': nuevoEstado,
      });
      return ConfiguracionParalelo.fromJson(response.data);
    } catch (e) {
      print('Error toggle paralelos: $e');
      throw Exception('Error al actualizar estado');
    }
  }
}
