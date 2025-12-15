import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/estudiante_service.dart';
import '../services/pago_service.dart';
import '../models/estudiante_response.dart';

class DashboardEstudiantePagosPage extends StatefulWidget {
  const DashboardEstudiantePagosPage({super.key});

  @override
  State<DashboardEstudiantePagosPage> createState() => _DashboardEstudiantePagosPageState();
}

class _DashboardEstudiantePagosPageState extends State<DashboardEstudiantePagosPage> {
  final _estudianteService = EstudianteService();
  final _pagoService = PagoService();

  bool _isLoading = true;
  EstudianteResponseDTO? _estudiante;
  List<dynamic> _deudas = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final est = await _estudianteService.obtenerPerfil();
      _estudiante = est;

      final deudas = await _pagoService.listarDeudas(est.idEstudiante);
      _deudas = deudas;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mis Pagos y Pensiones',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_estudiante == null) return const Center(child: Text('Datos no disponibles.'));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado de Cuenta: ${_estudiante?.nombres} ${_estudiante?.apellidoPaterno}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: _deudas.isEmpty
                ? const Center(child: Text('No tiene deudas pendientes.'))
                : ListView.builder(
                    itemCount: _deudas.length,
                    itemBuilder: (context, index) {
                      final deuda = _deudas[index];
                      // Map values from CuentaCobrarResponseDTO
                      final concepto = deuda['nombreTipoPago'] ?? 'Pago';
                      final total = deuda['montoTotal'] ?? 0;
                      final saldo = deuda['saldoPendiente'] ?? 0;
                      final estado = deuda['estado'] ?? 'DESCONOCIDO';
                      final vencimiento = deuda['fechaVencimiento'] ?? '-';

                      final esPagado = estado == 'PAGADO';

                      return Card(
                        color: esPagado ? Colors.green.shade50 : Colors.white,
                        child: ListTile(
                          leading: Icon(
                            esPagado ? Icons.check_circle : Icons.money_off,
                            color: esPagado ? Colors.green : Colors.red,
                          ),
                          title: Text(concepto.toString()),
                          subtitle: Text('Vence: $vencimiento\nEstado: $estado'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total: $total Bs.', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (!esPagado)
                                Text('Saldo: $saldo Bs.', style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
