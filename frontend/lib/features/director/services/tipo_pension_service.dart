import 'package:unidad_educatica_frontend/core/api.dart';

class TipoPensionService {
  // GET: Obtenemos los conceptos de una gestión
  Future<List<Map<String, dynamic>>> getTiposPension(int idGestion) async {
    final response = await dio.get('/finanzas/conceptos/gestion/$idGestion');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> crearTipoPension(Map<String, dynamic> data) async {
    await dio.post('/finanzas/conceptos', data: data);
  }

  Future<void> actualizarTipoPension(int id, Map<String, dynamic> data) async {
    await dio.put('/finanzas/conceptos/$id', data: data);
  }

  Future<void> eliminarTipoPension(int id) async {
    await dio.delete('/finanzas/conceptos/$id');
  }
}
