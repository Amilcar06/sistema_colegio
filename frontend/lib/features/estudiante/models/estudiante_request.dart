class EstudianteRequestDTO {
  final int idUsuario;
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String? fotoPerfilUrl;
  final String ci;
  final DateTime fechaNacimiento;
  final String telefonoPadre;
  final String telefonoMadre;
  final String direccion;

  EstudianteRequestDTO({
    required this.idUsuario,
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.correo,
    this.fotoPerfilUrl,
    required this.ci,
    required this.fechaNacimiento,
    required this.telefonoPadre,
    required this.telefonoMadre,
    required this.direccion,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'correo': correo,
      'fotoPerfilUrl': fotoPerfilUrl,
      'ci': ci,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'telefonoPadre': telefonoPadre,
      'telefonoMadre': telefonoMadre,
      'direccion': direccion,
    };
  }

  factory EstudianteRequestDTO.fromJson(Map<String, dynamic> json) {
    return EstudianteRequestDTO(
      idUsuario: json['idUsuario'],
      nombres: json['nombres'],
      apellidoPaterno: json['apellidoPaterno'],
      apellidoMaterno: json['apellidoMaterno'],
      correo: json['correo'],
      fotoPerfilUrl: json['fotoPerfilUrl'],
      ci: json['ci'],
      fechaNacimiento: DateTime.parse(json['fechaNacimiento']),
      telefonoPadre: json['telefonoPadre'],
      telefonoMadre: json['telefonoMadre'],
      direccion: json['direccion'],
    );
  }
}
