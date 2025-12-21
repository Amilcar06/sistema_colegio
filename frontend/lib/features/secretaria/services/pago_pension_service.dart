import '../../../../core/api.dart';

class PagoPensionService {


  Future<List<dynamic>> getDeudasEstudiante(int idEstudiante) async {
    final response = await dio.get('/finanzas/pagos/estudiante/$idEstudiante');
    return response.data;
  }

  Future<Map<String, dynamic>> registrarPago(Map<String, dynamic> data) async {
    final response = await dio.post('/finanzas/pagos', data: data);
    return response.data;
  }

  Future<List<dynamic>> getPagos({int? idEstudiante}) async {
    final response = await dio.get('/finanzas/pagos', queryParameters: {
      if (idEstudiante != null) 'idEstudiante': idEstudiante,
    });
    return response.data;
  }
  // Descargar Recibo
  Future<Uint8List> descargarRecibo(int idPago) async {
    final response = await dio.get(
      '/reportes/recibo/$idPago',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
}
