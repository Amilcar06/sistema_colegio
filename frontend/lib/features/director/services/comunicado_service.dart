import 'package:dio/dio.dart';
import '../../../../core/api_config.dart';
import '../../../../core/services/auth_service.dart';
import '../../comunicacion/models/comunicado.dart';

class ComunicadoService {
  final Dio _dio = Dio(); // Instancia propia para configurar base url si es necesario, o usar global
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

  Future<List<Comunicado>> listar() async {
    final options = await _getOptions();
    final response = await _dio.get('${ApiConfig.baseUrl}/api/comunicados', options: options);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Comunicado.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar comunicados');
    }
  }

  Future<void> crear(Map<String, dynamic> data) async {
    final options = await _getOptions();
    final response = await _dio.post('${ApiConfig.baseUrl}/api/comunicados', data: data, options: options);
    
    if (response.statusCode != 200 && response.statusCode != 201) {
       throw Exception('Error al crear comunicado');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> data) async {
    final options = await _getOptions();
    final response = await _dio.put('${ApiConfig.baseUrl}/api/comunicados/$id', data: data, options: options);

    if (response.statusCode != 200) {
       throw Exception('Error al actualizar comunicado');
    }
  }

  Future<void> eliminar(int id) async {
    final options = await _getOptions();
    final response = await _dio.delete('${ApiConfig.baseUrl}/api/comunicados/$id', options: options);

    if (response.statusCode != 204 && response.statusCode != 200) {
       throw Exception('Error al eliminar comunicado');
    }
  }
}

