class DashboardProfesorStats {
  final int totalCursos;
  final int totalEstudiantes;
  final int clasesHoy;

  DashboardProfesorStats({
    required this.totalCursos,
    required this.totalEstudiantes,
    required this.clasesHoy,
  });

  factory DashboardProfesorStats.fromJson(Map<String, dynamic> json) {
    return DashboardProfesorStats(
      totalCursos: json['totalCursos'] ?? 0,
      totalEstudiantes: json['totalEstudiantes'] ?? 0,
      clasesHoy: json['clasesHoy'] ?? 0,
    );
  }
}
