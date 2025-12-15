class UsuarioRequestDTO {
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String password;
  final int idRol;
  final bool estado;
  final String? fotoPerfilUrl;

  UsuarioRequestDTO({
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    required this.password,
    required this.idRol,
    this.estado = true,
    this.fotoPerfilUrl,
  });

  Map<String, dynamic> toJson() => {
    'nombres': nombres,
    'apellidoPaterno': apellidoPaterno,
    'apellidoMaterno': apellidoMaterno,
    'correo': correo,
    'password': password,
    'idRol': idRol,
    'estado': estado,
    'fotoPerfilUrl': fotoPerfilUrl,
  };
}
