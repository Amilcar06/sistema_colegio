import 'package:unidad_educatica_frontend/core/api.dart';
import '../../comunicacion/models/comunicado.dart';

class ComunicadoService {
  Future<List<Comunicado>> listar() async {
    final response = await dio.get('/comunicados');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Comunicado.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar comunicados');
    }
  }

  Future<void> crear(Map<String, dynamic> data) async {
    final response = await dio.post('/comunicados', data: data);
    if (response.statusCode != 200 && response.statusCode != 201) {
       throw Exception('Error al crear comunicado');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> data) async {
    final response = await dio.put('/comunicados/$id', data: data);
    if (response.statusCode != 200) {
       throw Exception('Error al actualizar comunicado');
    }
  }

  Future<void> eliminar(int id) async {
    final response = await dio.delete('/comunicados/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
       throw Exception('Error al eliminar comunicado');
    }
  }
}

