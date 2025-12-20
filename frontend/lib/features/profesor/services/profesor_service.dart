import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/api.dart';
import '../models/profesor_registro_completo.dart';
import '../models/profesor_response.dart';
import '../models/dashboard_profesor_stats.dart';
import '../models/asignacion_docente_response.dart';
import '../models/boletin_notas_model.dart';

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
    final Map<String, dynamic> data = dto.toJson();
    if (dto.password.isNotEmpty) {
      data['contrasena'] = dto.password; // Map to Backend DTO field
    } else {
        data.remove('password'); // Ensure clean JSON
    }
    // Also ensure field name mapping matching Backend ProfesorUpdateDTO (which uses 'contrasena')
    // ProfesorRegistroCompletoDTO.toJson() generally matches Request DTO. 
    // Let's verify if toJson uses 'contrasena' or 'password'.
    // Assuming toJson uses 'password', we should remap.
    // Actually, safer to build manual map like EstudianteService to be sure.
    
    final Map<String, dynamic> cleanData = {
        'nombres': dto.nombres,
        'apellidoPaterno': dto.apellidoPaterno,
        'apellidoMaterno': dto.apellidoMaterno,
        'correo': dto.correo,
        'ci': dto.ci,
        'telefono': dto.telefono,
        'profesion': dto.profesion,
        'fotoPerfil': dto.fotoPerfilUrl,
        'fechaNacimiento': dto.fechaNacimiento.toIso8601String().split('T')[0], // YYYY-MM-DD
        'contrasena': dto.password,
    };

    final response = await dio.put('/profesores/$idProfesor', data: cleanData);
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

  // Gradebook Methods
  Future<List<BoletinNotasModel>> getBoletinCurso(int idAsignacion, String trimestre) async {
    final response = await dio.get(
      '/notas/asignacion/$idAsignacion/boletin-curso', // Note: Endpoint changed in backend to match this? 
      // I defined endpoint as /asignacion/{id}/boletin-curso in backend controller step 417
      queryParameters: {'trimestre': trimestre},
    );
    return (response.data as List).map((e) => BoletinNotasModel.fromJson(e)).toList();
  }

  Future<void> guardarNotasBatch(int idAsignacion, String trimestre, List<BoletinNotasModel> notas) async {
    await dio.post(
      '/notas/asignacion/$idAsignacion/batch',
      queryParameters: {'trimestre': trimestre},
      data: notas.map((e) => e.toJson()).toList(),
    );
  }

  // Horarios
  Future<List<Map<String, dynamic>>> getMisHorarios() async {
    final response = await dio.get('/horarios/profesor/mis-horarios');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  // Comunicados
  Future<List<Map<String, dynamic>>> getComunicados() async {
    final response = await dio.get('/comunicados');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> enviarComunicado(Map<String, dynamic> data) async {
    await dio.post('/comunicados', data: data);
  }
}