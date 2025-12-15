class Grado {
  final int idGrado;
  final String nombre;
  final String nivel; // INICIAL, PRIMARIA, SECUNDARIA

  Grado({
    required this.idGrado,
    required this.nombre,
    required this.nivel,
  });

  factory Grado.fromJson(Map<String, dynamic> json) {
    return Grado(
      idGrado: json['idGrado'],
      nombre: json['nombre'],
      nivel: json['nivel'],
    );
  }
}
