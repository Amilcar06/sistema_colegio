import 'package:unidad_educatica_frontend/core/api.dart';
import '../models/notificacion_model.dart';

class NotificationService {
  Future<List<NotificacionResponseDTO>> obtenerMisNotificaciones() async {
    final response = await dio.get('/notificaciones/mis-notificaciones');
    return (response.data as List)
        .map((e) => NotificacionResponseDTO.fromJson(e))
        .toList();
  }

  Future<void> marcarComoLeida(int id) async {
    await dio.put('/notificaciones/$id/leer');
  }

  Future<int> contarNoLeidas() async {
    final response = await dio.get('/notificaciones/count-unread');
    return response.data;
  }
}
