import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api.dart';

class DashboardService {
  Future<Map<String, dynamic>> getStats() async {
    final response = await dio.get('/dashboard/stats');
    if (response.data is String) {
      return jsonDecode(response.data);
    }
    return response.data;
  }
}
