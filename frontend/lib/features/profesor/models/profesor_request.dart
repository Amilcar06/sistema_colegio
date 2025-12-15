class ProfesorRequestDTO {
  final String ci;
  final String telefono;
  final String? profesion;

  final int idUsuario;
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String? fotoPerfilUrl;

  ProfesorRequestDTO({
    required this.ci,
    required this.telefono,
    this.profesion,
    required this.idUsuario,
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    this.fotoPerfilUrl,
  });

  Map<String, dynamic> toJson() => {
    "ci": ci,
    "telefono": telefono,
    "profesion": profesion,
    "idUsuario": idUsuario,
    "nombres": nombres,
    "apellidoPaterno": apellidoPaterno,
    "apellidoMaterno": apellidoMaterno,
    "correo": correo,
    "fotoPerfilUrl": fotoPerfilUrl,
  };
}
