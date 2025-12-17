class Evento {
  final int idEvento;
  final String titulo;
  final String descripcion;
  final String fechaInicio;
  final String fechaFin;
  final String ubicacion;
  final String tipoEvento; // FERIADO, EXAMEN, ACTO_CIVICO, REUNION, OTRO

  Evento({
    required this.idEvento,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.ubicacion,
    required this.tipoEvento,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    // Handle array format if backend returns [yyyy, mm, dd...]
    String parseDate(dynamic date) {
      if (date is List) {
        if (date.isEmpty) return '';
        // yyyy-mm-ddTHH:mm:ss
        final y = date[0];
        final m = date.length > 1 ? date[1].toString().padLeft(2, '0') : '01';
        final d = date.length > 2 ? date[2].toString().padLeft(2, '0') : '01';
        final h = date.length > 3 ? date[3].toString().padLeft(2, '0') : '00';
        final min = date.length > 4 ? date[4].toString().padLeft(2, '0') : '00';
        return '$y-$m-${d}T$h:$min:00';
      }
      return date.toString();
    }

    return Evento(
      idEvento: json['idEvento'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaInicio: parseDate(json['fechaInicio']),
      fechaFin: parseDate(json['fechaFin']),
      ubicacion: json['ubicacion'] ?? '',
      tipoEvento: json['tipoEvento'] ?? 'OTRO',
    );
  }
}
