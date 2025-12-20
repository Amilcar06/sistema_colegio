import 'package:dio/dio.dart';
import '../../../../core/api_config.dart';
import '../../../../core/services/auth_service.dart';
import '../../comunicacion/models/evento.dart';

class EventoService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<Options> _getOptions() async {
    final token = await _authService.getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<List<Evento>> listar() async {
    final options = await _getOptions();
    final response = await _dio.get('${ApiConfig.baseUrl}/api/eventos', options: options);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Evento.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar eventos');
    }
  }

  Future<List<Evento>> listarHistorial() async {
    final options = await _getOptions();
    final response = await _dio.get('${ApiConfig.baseUrl}/api/eventos/historial', options: options);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Evento.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar historial de eventos');
    }
  }

  Future<void> crear(Map<String, dynamic> data) async {
    final options = await _getOptions();
    final response = await _dio.post('${ApiConfig.baseUrl}/api/eventos', data: data, options: options);

    if (response.statusCode != 200 && response.statusCode != 201) {
       throw Exception('Error al crear evento');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> data) async {
    final options = await _getOptions();
    final response = await _dio.put('${ApiConfig.baseUrl}/api/eventos/$id', data: data, options: options);

    if (response.statusCode != 200) {
       throw Exception('Error al actualizar evento');
    }
  }

  Future<void> eliminar(int id) async {
    final options = await _getOptions();
    final response = await _dio.delete('${ApiConfig.baseUrl}/api/eventos/$id', options: options);

    if (response.statusCode != 204 && response.statusCode != 200) {
       throw Exception('Error al eliminar evento');
    }
  }
}

