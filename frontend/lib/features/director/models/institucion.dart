class Institucion {
  final int? idUnidadEducativa;
  final String nombre;
  final String sie;
  final String? direccion;
  final String? logoUrl;

  Institucion({
    this.idUnidadEducativa,
    required this.nombre,
    required this.sie,
    this.direccion,
    this.logoUrl,
  });

  factory Institucion.fromJson(Map<String, dynamic> json) {
    return Institucion(
      idUnidadEducativa: json['idUnidadEducativa'],
      nombre: json['nombre'] ?? '',
      sie: json['sie'] ?? '',
      direccion: json['direccion'],
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUnidadEducativa': idUnidadEducativa,
      'nombre': nombre,
      'sie': sie,
      'direccion': direccion,
      'logoUrl': logoUrl,
    };
  }
}
