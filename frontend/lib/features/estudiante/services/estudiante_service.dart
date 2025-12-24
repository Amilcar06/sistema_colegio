import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:unidad_educatica_frontend/core/api.dart';
import '../models/estudiante_response.dart';
import 'package:unidad_educatica_frontend/shared/models/page_response.dart';
import '../models/estudiante_registro_completo.dart';
import '../models/estudiante_request.dart';

class EstudianteService {
  /// Registrar estudiante con datos completos (usuario + estudiante)
  Future<EstudianteResponseDTO> registrarEstudianteCompleto(EstudianteRegistroCompletoDTO dto) async {
    final response = await dio.post('/estudiantes/registro', data: dto.toJson());
    return EstudianteResponseDTO.fromJson(response.data);
  }

  /// Actualizar estudiante (por ID)
  Future<EstudianteResponseDTO> actualizarEstudiante(int idEstudiante, EstudianteRegistroCompletoDTO dto) async {
    final Map<String, dynamic> data = {
      'nombres': dto.nombres,
      'apellidoPaterno': dto.apellidoPaterno,
      'apellidoMaterno': dto.apellidoMaterno,
      'correo': dto.correo,
      'ci': dto.ci,
      'fotoPerfil': dto.fotoPerfilUrl,
      'fechaNacimiento': "${dto.fechaNacimiento.year}-${dto.fechaNacimiento.month.toString().padLeft(2, '0')}-${dto.fechaNacimiento.day.toString().padLeft(2, '0')}",
      'direccion': dto.direccion,
      'telefonoPadre': dto.telefonoPadre,
      'telefonoMadre': dto.telefonoMadre,
      'nombrePadre': dto.nombrePadre,
      'nombreMadre': dto.nombreMadre,
      'contrasena': dto.password, 
    };
    
    final response = await dio.put('/estudiantes/$idEstudiante', data: data);
    return EstudianteResponseDTO.fromJson(response.data);
  }

  /// Listar todos los estudiantes (DEPRECADO, usar listarPaginated)
  Future<List<EstudianteResponseDTO>> listar() async {
    final response = await dio.get('/estudiantes');
    return (response.data['content'] != null) 
        ? (response.data['content'] as List).map((e) => EstudianteResponseDTO.fromJson(e)).toList()
        : (response.data as List).map((e) => EstudianteResponseDTO.fromJson(e)).toList();
  }

  /// Listar estudiantes paginado
  Future<PageResponse<EstudianteResponseDTO>> listarPaginated({int page = 0, int size = 20, bool? activo}) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (activo != null) {
      query['activo'] = activo;
    }

    final response = await dio.get('/estudiantes', queryParameters: query);
    return PageResponse<EstudianteResponseDTO>.fromJson(
      response.data, 
      (json) => EstudianteResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Buscar estudiantes por CI
  Future<List<EstudianteResponseDTO>> buscarPorCI(String query) async {
    final response = await dio.get('/estudiantes/buscar', queryParameters: {'ci': query});
    return (response.data as List).map((e) => EstudianteResponseDTO.fromJson(e)).toList();
  }

  /// Obtener perfil del estudiante autenticado
  Future<EstudianteResponseDTO> obtenerPerfil() async {
    final response = await dio.get('/estudiantes/mi-perfil');
    return EstudianteResponseDTO.fromJson(response.data);
  }

  /// Obtener detalles de un estudiante por ID
  Future<EstudianteResponseDTO> obtenerEstudiantePorId(int idEstudiante) async {
    final response = await dio.get('/estudiantes/$idEstudiante');
    return EstudianteResponseDTO.fromJson(response.data);
  }

  /// Cambiar estado del estudiante
  Future<void> desactivarEstudiante(int idEstudiante) async {
    await dio.put('/estudiantes/$idEstudiante/desactivar');
  }

  /// Cambiar estado del usuario (campo booleano `estado`)
  Future<void> activarEstudiante(int idEstudiante) async {
    await dio.put('/estudiantes/$idEstudiante/activar');
  }

  /// Eliminar estudiante
  Future<void> eliminar(int idEstudiante) async {
    await dio.delete('/estudiantes/$idEstudiante');
  }

  /// Descargar Boletín de Notas (PDF)
  Future<Uint8List> descargarBoletin(int idEstudiante, {int? idGestion}) async {
    final query = idGestion != null ? {'gestion': idGestion} : null;
    final response = await dio.get(
      '/reportes/boletin/$idEstudiante',
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }

  /// Listar gestiones donde el estudiante ha estado inscrito
  Future<List<Map<String, dynamic>>> listarGestiones(int idEstudiante) async {
    final response = await dio.get('/estudiantes/$idEstudiante/gestiones');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
