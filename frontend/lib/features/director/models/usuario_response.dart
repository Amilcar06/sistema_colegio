import 'rol_response.dart';

class UsuarioResponseDTO {
  final int idUsuario;
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String ci;
  final String? fotoPerfil;
  final bool estado;
  final RolResponseDTO rol;

  // Alias for compatibility
  String? get fotoPerfilUrl => fotoPerfil;

  UsuarioResponseDTO({
    required this.idUsuario,
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    required this.ci,
    required this.estado,
    required this.rol,
    this.fotoPerfil,
  });

  factory UsuarioResponseDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioResponseDTO(
      idUsuario: json['idUsuario'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidoPaterno: json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellidoMaterno'],
      correo: json['correo'] ?? '',
      ci: json['ci'] ?? '',
      estado: json['estado'] ?? false,
      rol: RolResponseDTO.fromJson(json['rol']),
      fotoPerfil: json['fotoPerfil'] ?? json['fotoPerfilUrl'],
    );
  }
}
