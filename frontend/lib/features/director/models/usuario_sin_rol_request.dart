class UsuarioSinRolRequestDTO {
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String ci; // Added CI
  final String password;
  final bool estado;
  final String? fotoPerfilUrl;

  UsuarioSinRolRequestDTO({
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.ci, // Added CI
    required this.correo,
    required this.password,
    this.estado = true,
    this.fotoPerfilUrl,
  });

  Map<String, dynamic> toJson() => {
    'nombres': nombres,
    'apellidoPaterno': apellidoPaterno,
    'apellidoMaterno': apellidoMaterno,
    'ci': ci, // Added CI
    'correo': correo,
    'contrasena': password, // Renamed to match backend
    'fotoPerfil': fotoPerfilUrl, // Renamed to match backend
  };
}
