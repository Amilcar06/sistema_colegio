import 'package:unidad_educatica_frontend/core/api.dart';
import '../models/estudiante_response.dart';
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
    final response = await dio.put('/estudiantes/$idEstudiante', data: dto.toJson());
    return EstudianteResponseDTO.fromJson(response.data);
  }

  /// Listar todos los estudiantes
  Future<List<EstudianteResponseDTO>> listar() async {
    final response = await dio.get('/estudiantes');
    return (response.data as List)
        .map((e) => EstudianteResponseDTO.fromJson(e))
        .toList();
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
}
