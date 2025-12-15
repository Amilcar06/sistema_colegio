class ProfesorResponseDTO {
  final int idProfesor;
  final String ci;
  final String telefono;
  final String? profesion;
  final int idUsuario;
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final bool estado;

  ProfesorResponseDTO({
    required this.idProfesor,
    required this.ci,
    required this.telefono,
    this.profesion,
    required this.idUsuario,
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    required this.estado,
  });

  factory ProfesorResponseDTO.fromJson(Map<String, dynamic> json) => ProfesorResponseDTO(
    idProfesor: json['idProfesor'],
    ci: json['ci'],
    telefono: json['telefono'],
    profesion: json['profesion'],
    idUsuario: json['idUsuario'],
    nombres: json['nombres'],
    apellidoPaterno: json['apellidoPaterno'],
    apellidoMaterno: json['apellidoMaterno'],
    correo: json['correo'],
    estado: json['estado'] ?? true,
  );
}