import 'package:dio/dio.dart';
import '../../../../core/api.dart';

class ReporteService {
  Future<Map<String, dynamic>> getReporteIngresos(int anio, int mes) async {
    try {
      final response = await dio.get('/reportes/ingresos', queryParameters: {
        'year': anio,
        'month': mes,
      });
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener reporte de ingresos: $e');
    }
  }

  Future<List<dynamic>> getListaMorosos() async {
    try {
      final response = await dio.get('/reportes/morosos');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener lista de morosos: $e');
    }
  }

  Future<List<dynamic>> getUltimasTransacciones() async {
    try {
      final response = await dio.get('/reportes/transacciones');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener transacciones: $e');
    }
  }
}
