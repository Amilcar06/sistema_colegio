class UsuarioRequestDTO {
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String? password;
  final int idRol;
  final bool estado;
  final String? fotoPerfilUrl;
  final String? ci;
  final String? fechaNacimiento; // YYYY-MM-DD
  final int? idUnidadEducativa;

  UsuarioRequestDTO({
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    this.password,
    required this.idRol,
    this.estado = true,
    this.fotoPerfilUrl,
    this.ci,
    this.fechaNacimiento,
    this.idUnidadEducativa,
  });

  Map<String, dynamic> toJson() => {
    'nombres': nombres,
    'apellidoPaterno': apellidoPaterno,
    'apellidoMaterno': apellidoMaterno,
    'correo': correo,
    if (password != null) 'password': password,
    'idRol': idRol,
    'estado': estado,
    'fotoPerfil': fotoPerfilUrl, // Backend expects 'fotoPerfil'
    'ci': ci,
    'fechaNacimiento': fechaNacimiento,
    'idUnidadEducativa': idUnidadEducativa,
  };
}
