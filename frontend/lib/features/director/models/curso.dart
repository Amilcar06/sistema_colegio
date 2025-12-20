class Curso {
  final int idCurso;
  final int idGrado;
  final String nombreGrado;
  final String nivel;
  final String paralelo;
  final String turno; // MANANA, TARDE, NOCHE

  Curso({
    required this.idCurso,
    required this.idGrado,
    required this.nombreGrado,
    required this.nivel,
    required this.paralelo,
    required this.turno,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      idCurso: json['idCurso'],
      idGrado: json['idGrado'],
      nombreGrado: json['nombreGrado'],
      nivel: json['nivel'],
      paralelo: json['paralelo'],
      turno: json['turno'],
    );
  }

  // Helper getters
  // Helper getters
  String get nombreCompleto => '$nombreGrado "$paralelo"';
  String get gradoNombre => nombreGrado; // Compatibility getter
}
