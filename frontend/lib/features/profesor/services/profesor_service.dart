import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/api.dart';
import '../models/profesor_registro_completo.dart';
import '../models/profesor_response.dart';
import '../models/dashboard_profesor_stats.dart';
import '../models/asignacion_docente_response.dart';

class ProfesorService {
  Future<List<ProfesorResponseDTO>> listarProfesores() async {
    final response = await dio.get('/profesores');
    return (response.data as List)
        .map((e) => ProfesorResponseDTO.fromJson(e))
        .toList();
  }

  Future<ProfesorResponseDTO> registrarProfesorCompleto(ProfesorRegistroCompletoDTO dto) async {
    final response = await dio.post('/profesores/registro', data: dto.toJson());
    return ProfesorResponseDTO.fromJson(response.data);
  }

  Future<ProfesorResponseDTO> actualizarProfesor(int idProfesor, ProfesorRegistroCompletoDTO dto) async {
    final response = await dio.put('/profesores/$idProfesor', data: dto.toJson());
    return ProfesorResponseDTO.fromJson(response.data);
  }

  Future<void> eliminarProfesor(int idProfesor) async {
    await dio.delete('/profesores/$idProfesor');
  }

  Future<void> activarProfesor(int idProfesor) async {
    await dio.put('/profesores/$idProfesor/activar');
  }

  Future<void> desactivarProfesor(int idProfesor) async {
    await dio.put('/profesores/$idProfesor/desactivar');
  }

  Future<ProfesorResponseDTO> obtenerProfesorPorId(int idProfesor) async {
    final response = await dio.get('/profesores/$idProfesor');
    return ProfesorResponseDTO.fromJson(response.data);
  }

  Future<ProfesorResponseDTO> obtenerPerfil() async {
    final response = await dio.get('/profesores/mi-perfil');
    return ProfesorResponseDTO.fromJson(response.data);
  }

  Future<DashboardProfesorStats> getDashboardStats() async {
    final response = await dio.get('/profesores/dashboard-stats');
    return DashboardProfesorStats.fromJson(response.data);
  }

  Future<List<AsignacionDocenteResponse>> getMisCursos() async {
    final response = await dio.get('/asignaciones/mis-cursos');
    return (response.data as List)
        .map((e) => AsignacionDocenteResponse.fromJson(e))
        .toList();
  }

  Future<dynamic> getLibreta(String idAsignacion) async {
    final response = await dio.get('/notas/asignacion/$idAsignacion/libreta');
    return response.data; // Retorna LibretaDigitalDTO (Map)
  }

  Future<void> registrarNota(Map<String, dynamic> data) async {
    await dio.post('/notas', data: data);
  }

  Future<void> actualizarNota(int idNota, Map<String, dynamic> data) async {
    await dio.put('/notas/$idNota', data: data);
  }

  // Descargar Lista de Estudiantes
  Future<Uint8List> descargarListaCurso(int idCurso) async {
    final response = await dio.get(
      '/reportes/curso/$idCurso',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
}