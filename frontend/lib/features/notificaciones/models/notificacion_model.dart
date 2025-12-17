class NotificacionResponseDTO {
  final int idNotificacion;
  final String titulo;
  final String mensaje;
  final bool leido;
  final String fechaCreacion;

  NotificacionResponseDTO({
    required this.idNotificacion,
    required this.titulo,
    required this.mensaje,
    required this.leido,
    required this.fechaCreacion,
  });

  factory NotificacionResponseDTO.fromJson(Map<String, dynamic> json) {
    return NotificacionResponseDTO(
      idNotificacion: json['idNotificacion'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      leido: json['leido'],
      fechaCreacion: json['fechaCreacion'],
    );
  }
}
