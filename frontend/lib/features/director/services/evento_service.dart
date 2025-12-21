import 'package:unidad_educatica_frontend/core/api.dart';
import '../../comunicacion/models/evento.dart';

class EventoService {
  Future<List<Evento>> listar() async {
    final response = await dio.get('/eventos');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Evento.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar eventos');
    }
  }

  Future<List<Evento>> listarHistorial() async {
    final response = await dio.get('/eventos/historial');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Evento.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar historial de eventos');
    }
  }

  Future<void> crear(Map<String, dynamic> data) async {
    final response = await dio.post('/eventos', data: data);
    if (response.statusCode != 200 && response.statusCode != 201) {
       throw Exception('Error al crear evento');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> data) async {
    final response = await dio.put('/eventos/$id', data: data);
    if (response.statusCode != 200) {
       throw Exception('Error al actualizar evento');
    }
  }

  Future<void> eliminar(int id) async {
    final response = await dio.delete('/eventos/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
       throw Exception('Error al eliminar evento');
    }
  }
}

