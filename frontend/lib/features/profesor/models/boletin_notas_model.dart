class BoletinNotasModel {
  final int idEstudiante;
  final String nombreEstudiante;
  final int? idNota;
  
  // Dimensions
  double ser;
  double saber;
  double hacer;
  double decidir;
  double autoevaluacion;
  double notaFinal;

  BoletinNotasModel({
    required this.idEstudiante,
    required this.nombreEstudiante,
    this.idNota,
    this.ser = 0.0,
    this.saber = 0.0,
    this.hacer = 0.0,
    this.decidir = 0.0,
    this.autoevaluacion = 0.0,
    this.notaFinal = 0.0,
  });

  factory BoletinNotasModel.fromJson(Map<String, dynamic> json) {
    return BoletinNotasModel(
      idEstudiante: json['idEstudiante'],
      nombreEstudiante: json['nombreEstudiante'],
      idNota: json['idNota'],
      ser: (json['ser'] ?? 0.0).toDouble(),
      saber: (json['saber'] ?? 0.0).toDouble(),
      hacer: (json['hacer'] ?? 0.0).toDouble(),
      decidir: (json['decidir'] ?? 0.0).toDouble(),
      autoevaluacion: (json['autoevaluacion'] ?? 0.0).toDouble(),
      notaFinal: (json['notaFinal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEstudiante': idEstudiante,
      'nombreEstudiante': nombreEstudiante,
      'idNota': idNota,
      'ser': ser,
      'saber': saber,
      'hacer': hacer,
      'decidir': decidir,
      'autoevaluacion': autoevaluacion,
      'notaFinal': notaFinal,
    };
  }
}
