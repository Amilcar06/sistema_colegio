import 'rol_response.dart';

class UsuarioResponseDTO {
  final int idUsuario;
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String ci;
  final String? fotoPerfilUrl;
  final bool estado;
  final RolResponseDTO rol;

  UsuarioResponseDTO({
    required this.idUsuario,
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.ci,
    required this.correo,
    this.fotoPerfilUrl,
    required this.estado,
    required this.rol,
  });

  factory UsuarioResponseDTO.fromJson(Map<String, dynamic> json) => UsuarioResponseDTO(
    idUsuario: json['idUsuario'] ?? 0,
    nombres: json['nombres'] ?? '',
    apellidoPaterno: json['apellidoPaterno'] ?? '',
    apellidoMaterno: json['apellidoMaterno'],
    ci: json['ci'] ?? '',
    correo: json['correo'] ?? '',
    fotoPerfilUrl: json['fotoPerfilUrl'],
    estado: json['estado'] ?? false,
    rol: RolResponseDTO.fromJson(json['rol']),
  );
}
