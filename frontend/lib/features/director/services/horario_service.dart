import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_config.dart';
import '../../../core/services/auth_service.dart';

class HorarioService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Crear horario
  Future<void> crearHorario(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/horarios'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al crear horario: ${response.body}');
    }
  }

  // Actualizar horario
  Future<void> updateHorario(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/horarios/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar horario: ${response.body}');
    }
  }

  // Eliminar horario
  Future<void> eliminarHorario(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/horarios/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar horario');
    }
  }

  // Listar por curso
  Future<List<dynamic>> listarPorCurso(int idCurso) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/horarios/curso/$idCurso'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al cargar horarios del curso');
    }
  }

  // Listar por profesor
  Future<List<dynamic>> listarPorProfesor(int idProfesor) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/horarios/profesor/$idProfesor'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al cargar horarios del profesor');
    }
  }
}
