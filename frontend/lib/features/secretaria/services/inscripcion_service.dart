import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_config.dart';
import '../../../core/services/auth_service.dart';

class InscripcionService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> registrarInscripcion(int idEstudiante, int idCurso) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'idEstudiante': idEstudiante,
      'idCurso': idCurso,
    });

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/inscripciones'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retorna la inscripción creada
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al registrar inscripción');
    }
  }

  Future<List<dynamic>> listarPorGestion(int idGestion) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/inscripciones/gestion/$idGestion'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al cargar inscripciones');
    }
  }

  Future<List<dynamic>> listarPorEstudiante(int idEstudiante) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/inscripciones/estudiante/$idEstudiante'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al cargar inscripciones del estudiante');
    }
  }
}
