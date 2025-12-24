class ItemEstadoCuenta {
  final int idCuentaCobrar;
  final String concepto;
  final double monto;
  final double saldoPendiente;
  final String estado;
  final DateTime? fechaVencimiento;
  final int diasRetraso;
  final bool esMensualidad;

  ItemEstadoCuenta({
    required this.idCuentaCobrar,
    required this.concepto,
    required this.monto,
    required this.saldoPendiente,
    required this.estado,
    this.fechaVencimiento,
    required this.diasRetraso,
    required this.esMensualidad,
  });

  factory ItemEstadoCuenta.fromJson(Map<String, dynamic> json) {
    return ItemEstadoCuenta(
      idCuentaCobrar: json['idCuentaCobrar'],
      concepto: json['concepto'],
      monto: (json['monto'] as num).toDouble(),
      saldoPendiente: (json['saldoPendiente'] as num).toDouble(),
      estado: json['estado'],
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'])
          : null,
      diasRetraso: json['diasRetraso'] ?? 0,
      esMensualidad: json['esMensualidad'] ?? false,
    );
  }
}

class ResumenCuenta {
  final double totalDeuda;
  final double totalPagado;
  final int mensualidadesPagadas;
  final int mensualidadesPendientes;
  final int mensualidadesVencidas;

  ResumenCuenta({
    required this.totalDeuda,
    required this.totalPagado,
    required this.mensualidadesPagadas,
    required this.mensualidadesPendientes,
    required this.mensualidadesVencidas,
  });

  factory ResumenCuenta.fromJson(Map<String, dynamic> json) {
    return ResumenCuenta(
      totalDeuda: (json['totalDeuda'] as num).toDouble(),
      totalPagado: (json['totalPagado'] as num).toDouble(),
      mensualidadesPagadas: json['mensualidadesPagadas'],
      mensualidadesPendientes: json['mensualidadesPendientes'],
      mensualidadesVencidas: json['mensualidadesVencidas'],
    );
  }
}

class EstadoCuenta {
  final List<ItemEstadoCuenta> mensualidades;
  final List<ItemEstadoCuenta> extras;
  final ResumenCuenta resumen;

  EstadoCuenta({
    required this.mensualidades,
    required this.extras,
    required this.resumen,
  });

  factory EstadoCuenta.fromJson(Map<String, dynamic> json) {
    return EstadoCuenta(
      mensualidades: (json['mensualidades'] as List)
          .map((i) => ItemEstadoCuenta.fromJson(i))
          .toList(),
      extras: (json['extras'] as List)
          .map((i) => ItemEstadoCuenta.fromJson(i))
          .toList(),
      resumen: ResumenCuenta.fromJson(json['resumen']),
    );
  }
}
