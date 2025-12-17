class Comunicado {
  final int idComunicado;
  final String titulo;
  final String contenido;
  final String fechaPublicacion;
  final String prioridad; // BAJA, MEDIA, ALTA
  final String tipoDestinatario; // TODOS, CURSO, ETC
  final String nombreAutor;

  Comunicado({
    required this.idComunicado,
    required this.titulo,
    required this.contenido,
    required this.fechaPublicacion,
    required this.prioridad,
    required this.tipoDestinatario,
    required this.nombreAutor,
  });

  factory Comunicado.fromJson(Map<String, dynamic> json) {
    return Comunicado(
      idComunicado: json['idComunicado'],
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      fechaPublicacion: json['fechaPublicacion'] ?? '',
      prioridad: json['prioridad'] ?? 'BAJA',
      tipoDestinatario: json['tipoDestinatario'] ?? 'TODOS',
      nombreAutor: json['nombreAutor'] ?? 'Anonimo',
    );
  }
}
