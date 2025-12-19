class AsignacionDocenteResponse {
  final int idAsignacion;
  final int idProfesor;
  final String nombreProfesor;
  final int idMateria;
  final String nombreMateria;
  final int idCurso;
  final String nombreCurso;
  final int idGestion;
  final int anioGestion;
  final bool estado;

  AsignacionDocenteResponse({
    required this.idAsignacion,
    required this.idProfesor,
    required this.nombreProfesor,
    required this.idMateria,
    required this.nombreMateria,
    required this.idCurso,
    required this.nombreCurso,
    required this.idGestion,
    required this.anioGestion,
    required this.estado,
  });

  factory AsignacionDocenteResponse.fromJson(Map<String, dynamic> json) {
    return AsignacionDocenteResponse(
      idAsignacion: json['idAsignacion'] ?? 0,
      idProfesor: json['idProfesor'] ?? 0,
      nombreProfesor: json['nombreProfesor'] ?? '',
      idMateria: json['idMateria'] ?? 0,
      nombreMateria: json['nombreMateria'] ?? '',
      idCurso: json['idCurso'] ?? 0,
      nombreCurso: json['nombreCurso'] ?? '',
      idGestion: json['idGestion'] ?? 0,
      anioGestion: json['anioGestion'] ?? 0,
      estado: json['estado'] ?? false,
    );
  }
}
