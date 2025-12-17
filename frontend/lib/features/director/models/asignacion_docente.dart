class AsignacionDocente {
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

  AsignacionDocente({
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

  factory AsignacionDocente.fromJson(Map<String, dynamic> json) {
    return AsignacionDocente(
      idAsignacion: json['idAsignacion'],
      idProfesor: json['idProfesor'],
      nombreProfesor: json['nombreProfesor'] ?? 'Sin nombre',
      idMateria: json['idMateria'],
      nombreMateria: json['nombreMateria'] ?? 'Sin materia',
      idCurso: json['idCurso'],
      nombreCurso: json['nombreCurso'] ?? '',
      idGestion: json['idGestion'] ?? 0,
      anioGestion: json['anioGestion'] ?? 0,
      estado: json['estado'] ?? true,
    );
  }
}
