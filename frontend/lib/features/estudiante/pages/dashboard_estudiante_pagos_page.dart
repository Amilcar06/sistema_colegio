import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/estudiante_service.dart';
import '../services/pago_service.dart';
import '../models/estudiante_response.dart';
import 'package:intl/intl.dart';

class DashboardEstudiantePagosPage extends StatefulWidget {
  const DashboardEstudiantePagosPage({super.key});

  @override
  State<DashboardEstudiantePagosPage> createState() => _DashboardEstudiantePagosPageState();
}

class _DashboardEstudiantePagosPageState extends State<DashboardEstudiantePagosPage> with SingleTickerProviderStateMixin {
  final _estudianteService = EstudianteService();
  final _pagoService = PagoService();
  late TabController _tabController;

  bool _isLoading = true;
  EstudianteResponseDTO? _estudiante;
  List<dynamic> _todasLasCuentas = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final est = await _estudianteService.obtenerPerfil();
      _estudiante = est;

      // listarDeudas devuelve todas las cuentas por cobrar?
      // asumimos que sí. Si solo devuelve PENDIENTES, entonces necesitamos otro endpoint para HISTORIAL (pagados).
      // Por ahora, filtraremos en memoria si trae todo.
      final cuentas = await _pagoService.listarDeudas(est.idEstudiante);
      _todasLasCuentas = cuentas;
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
      title: 'Estado de Cuenta',
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Pendientes'),
                Tab(text: 'Historial'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text('Error: $_error'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPendientesList(),
                      _buildHistorialList(), // En realidad esto debería ir en Comprobantes según el plan, pero lo dejamos aquí como referencia rápida
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendientesList() {
    final pendientes = _todasLasCuentas.where((c) => c['estado'] != 'PAGADO').toList();

    if (pendientes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('¡Todo al día!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('No tienes deudas pendientes.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendientes.length,
      itemBuilder: (context, index) {
        final item = pendientes[index];
        final concepto = item['nombreTipoPago'] ?? 'Pago';
        final total = item['montoTotal'] ?? 0;
        final saldo = item['saldoPendiente'] ?? 0;
        final vencimiento = item['fechaVencimiento']; // String YYYY-MM-DD
        
        bool vencido = false;
        if (vencimiento != null) {
          try {
             final fechaVen = DateTime.parse(vencimiento);
             if (fechaVen.isBefore(DateTime.now())) {
               vencido = true;
             }
          } catch (_) {}
        }

        return Card(
          elevation: 2,
          color: vencido ? Colors.red.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: vencido ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(concepto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: vencido ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vencido ? 'VENCIDO' : 'PENDIENTE',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Vence: ${vencimiento ?? 'N/A'}', style: TextStyle(
                      color: vencido ? Colors.red : Colors.grey.shade700
                    )),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('Monto Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                         Text('$total Bs.', style: const TextStyle(fontWeight: FontWeight.bold)),
                       ],
                     ),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                         const Text('Saldo a Pagar', style: TextStyle(fontSize: 12, color: Colors.red)),
                         Text('$saldo Bs.', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                       ],
                     ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Opcional: Mostrar historial aquí también, aunque lo importante es Comprobantes
  Widget _buildHistorialList() {
    final pagados = _todasLasCuentas.where((c) => c['estado'] == 'PAGADO').toList();
    
    if (pagados.isEmpty) {
      return const Center(child: Text("No hay pagos registrados en el historial"));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pagados.length,
      itemBuilder: (context, index) {
        final item = pagados[index];
         return ListTile(
           leading: const Icon(Icons.check_circle, color: Colors.green),
           title: Text(item['nombreTipoPago'] ?? 'Pago'),
           subtitle: const Text('Pagado completamente'),
           trailing: Text('${item['montoTotal']} Bs.', style: const TextStyle(fontWeight: FontWeight.bold)),
         );
      },
    );
  }
}
