import 'package:dio/dio.dart';
import '../../../../core/api.dart';

class ComunicadoService {
  final Dio _dio = dio;

  Future<List<dynamic>> listar() async {
    final response = await _dio.get('/comunicados');
    return response.data;
  }

  Future<dynamic> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/comunicados', data: data);
    return response.data;
  }
}
