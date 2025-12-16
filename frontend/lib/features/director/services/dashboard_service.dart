import 'package:dio/dio.dart';
import '../../../../core/api.dart';

class DashboardService {
  Future<Map<String, dynamic>> getStats() async {
    final response = await dio.get('/dashboard/stats');
    return response.data;
  }
}
