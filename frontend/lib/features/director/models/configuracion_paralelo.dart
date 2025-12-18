class ConfiguracionParalelo {
  final int id;
  final String nombre;
  final bool activo;
  final int orden;

  ConfiguracionParalelo({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.orden,
  });

  factory ConfiguracionParalelo.fromJson(Map<String, dynamic> json) {
    return ConfiguracionParalelo(
      id: json['id'],
      nombre: json['nombre'],
      activo: json['activo'],
      // Manejo seguro por si el backend envía int o num
      orden: json['orden'] is int ? json['orden'] : (json['orden'] as num).toInt(),
    );
  }
}
