import '../../estudiante/models/estudiante_response.dart';
import '../../director/models/curso.dart';

class InscripcionResponseDTO {
  final int idInscripcion;
  final EstudianteResponseDTO estudiante;
  final Curso curso;
  final String fechaInscripcion;
  final bool activo;
  final String estado;

  InscripcionResponseDTO({
    required this.idInscripcion,
    required this.estudiante,
    required this.curso,
    required this.fechaInscripcion,
    required this.activo,
    required this.estado,
  });

  factory InscripcionResponseDTO.fromJson(Map<String, dynamic> json) {
    return InscripcionResponseDTO(
      idInscripcion: json['idInscripcion'],
      estudiante: EstudianteResponseDTO.fromJson(json['estudiante']),
      curso: Curso.fromJson(json['curso']),
      fechaInscripcion: json['fechaInscripcion'],
      activo: json['activo'],
      estado: json['estado'],
    );
  }
}
