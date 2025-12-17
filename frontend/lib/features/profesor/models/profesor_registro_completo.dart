class ProfesorRegistroCompletoDTO {
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String password;
  final String? fotoPerfilUrl;
  final String ci;
  final String telefono;
  final String? profesion;
  final DateTime fechaNacimiento;

  ProfesorRegistroCompletoDTO({
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    required this.password,
    this.fotoPerfilUrl,
    required this.ci,
    required this.telefono,
    this.profesion,
    required this.fechaNacimiento,
  });

  Map<String, dynamic> toJson() => {
    'nombres': nombres,
    'apellidoPaterno': apellidoPaterno,
    'apellidoMaterno': apellidoMaterno,
    'correo': correo,
    'contrasena': password,
    'fotoPerfil': fotoPerfilUrl,
    'ci': ci,
    'telefono': telefono,
    'profesion': profesion,
    'fechaNacimiento': fechaNacimiento.toIso8601String().split('T')[0],
  };
}