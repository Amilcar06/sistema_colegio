class EstudianteRegistroCompletoDTO {
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String password;
  final String? fotoPerfilUrl;
  final String ci;
  final String direccion;
  final String telefonoPadre;
  final String telefonoMadre;
  final DateTime fechaNacimiento;

  EstudianteRegistroCompletoDTO({
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    required this.password,
    this.fotoPerfilUrl,
    required this.ci,
    required this.direccion,
    required this.telefonoPadre,
    required this.telefonoMadre,
    required this.fechaNacimiento,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'correo': correo,
      'password': password,
      'fotoPerfilUrl': fotoPerfilUrl,
      'ci': ci,
      'direccion': direccion,
      'telefonoPadre': telefonoPadre,
      'telefonoMadre': telefonoMadre,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
    };
  }
}
