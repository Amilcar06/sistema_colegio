import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unidad_educatica_frontend/core/api_config.dart';
import 'package:unidad_educatica_frontend/core/services/auth_service.dart';

class TipoPensionService {
  final AuthService _authService = AuthService();

  // GET: Obtenemos los conceptos de una gestión (por ahora hardcoded o pasada por param)
  // Como el backend pide idGestion, debemos enviarlo.
  // Podríamos obtener la gestión activa primero, pero por simplicidad
  // haremos que el backend devuelva todo o manejaremos la gestión en el UI.
  // UPDATE: El endpoint es /api/finanzas/conceptos/gestion/{idGestion}
  Future<List<Map<String, dynamic>>> getTiposPension(int idGestion) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/finanzas/conceptos/gestion/$idGestion');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar conceptos: ${response.body}');
    }
  }

  Future<void> crearTipoPension(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/finanzas/conceptos');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al crear concepto: ${response.body}');
    }
  }

  Future<void> actualizarTipoPension(int id, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/finanzas/conceptos/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar concepto: ${response.body}');
    }
  }

  Future<void> eliminarTipoPension(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/finanzas/conceptos/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
       // Si intenta borrar algo con deudas, lanzará excepción aquí
      throw Exception('Error al eliminar concepto: ${response.body}');
    }
  }
}
