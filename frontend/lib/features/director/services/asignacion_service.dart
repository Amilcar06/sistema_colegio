import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_config.dart';
import '../../../core/services/auth_service.dart';
import '../models/asignacion_docente.dart';

class AsignacionService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<AsignacionDocente>> listarPorCurso(int idCurso) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/asignaciones/curso/$idCurso'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => AsignacionDocente.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar asignaciones: ${response.body}');
    }
  }

  Future<void> crearAsignacion(int idCurso, int idMateria, int idProfesor, int gestionId) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'idCurso': idCurso,
      'idMateria': idMateria,
      'idProfesor': idProfesor,
      'idGestion': gestionId,
    });

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/asignaciones'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear asignación: ${response.body}');
    }
  }

  Future<void> actualizarAsignacion(int idAsignacion, int idCurso, int idMateria, int idProfesor, int gestionId) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'idCurso': idCurso,
      'idMateria': idMateria,
      'idProfesor': idProfesor,
      'idGestion': gestionId,
    });

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/asignaciones/$idAsignacion'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar asignación: ${response.body}');
    }
  }

  Future<void> eliminarAsignacion(int idAsignacion) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/asignaciones/$idAsignacion'),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar asignación: ${response.body}');
    }
  }
}
