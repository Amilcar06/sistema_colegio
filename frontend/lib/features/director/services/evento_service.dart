import 'package:dio/dio.dart';
import '../../../../core/api.dart';

class EventoService {
  final Dio _dio = dio;

  Future<List<dynamic>> listar() async {
    final response = await _dio.get('/eventos');
    return response.data;
  }

  Future<dynamic> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/eventos', data: data);
    return response.data;
  }
}
