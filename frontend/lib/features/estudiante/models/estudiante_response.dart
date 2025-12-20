class EstudianteResponseDTO {
  final int idEstudiante;
  final String ci;
  final DateTime fechaNacimiento;
  final String telefonoPadre;
  final String telefonoMadre;
  final String? nombrePadre;
  final String? nombreMadre;
  final String direccion;

  final int idUsuario;
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final bool estado;

  String get nombreCompleto => '$nombres $apellidoPaterno ${apellidoMaterno ?? ''}'.trim();

  EstudianteResponseDTO({
    required this.idEstudiante,
    required this.ci,
    required this.fechaNacimiento,
    required this.telefonoPadre,
    required this.telefonoMadre,
    this.nombrePadre,
    this.nombreMadre,
    required this.direccion,
    required this.idUsuario,
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    required this.estado,
  });

  factory EstudianteResponseDTO.fromJson(Map<String, dynamic> json) {
    return EstudianteResponseDTO(
      idEstudiante: json['idEstudiante'] ?? 0,
      ci: json['ci'] ?? '',
      fechaNacimiento: json['fechaNacimiento'] != null ? DateTime.parse(json['fechaNacimiento']) : DateTime.now(),
      telefonoPadre: json['telefonoPadre']?.toString() ?? '',
      telefonoMadre: json['telefonoMadre']?.toString() ?? '',
      nombrePadre: json['nombrePadre']?.toString() ?? '',
      nombreMadre: json['nombreMadre']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      idUsuario: json['idUsuario'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidoPaterno: json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellidoMaterno']?.toString() ?? '',
      correo: json['correo'] ?? '',
      estado: json['estado'] ?? true,
    );
  }
}
