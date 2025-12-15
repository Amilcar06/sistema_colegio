class Materia {
  final int idMateria;
  final String nombre;

  Materia({
    required this.idMateria,
    required this.nombre,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      idMateria: json['idMateria'],
      nombre: json['nombre'],
    );
  }
}
