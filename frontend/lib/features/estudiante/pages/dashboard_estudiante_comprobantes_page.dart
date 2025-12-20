import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../shared/services/pdf_service.dart';
import '../services/estudiante_service.dart';
import '../services/pago_service.dart';
import '../models/estudiante_response.dart';
import 'package:intl/intl.dart';

class DashboardEstudianteComprobantesPage extends StatefulWidget {
  const DashboardEstudianteComprobantesPage({super.key});

  @override
  State<DashboardEstudianteComprobantesPage> createState() => _DashboardEstudianteComprobantesPageState();
}

class _DashboardEstudianteComprobantesPageState extends State<DashboardEstudianteComprobantesPage> {
  final _estudianteService = EstudianteService();
  final _pagoService = PagoService();

  bool _isLoading = true;
  EstudianteResponseDTO? _estudiante;
  List<dynamic> _recibos = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarRecibos();
  }

  Future<void> _cargarRecibos() async {
    setState(() => _isLoading = true);
    try {
      final est = await _estudianteService.obtenerPerfil();
      _estudiante = est;

      // Usamos listarPagos para obtener transacciones reales
      _recibos = await _pagoService.listarPagos(idEstudiante: est.idEstudiante);
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _descargarRecibo(int idPago, String concepto) async {
    try {
      await PdfService.descargarRecibo(idPago); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descargando recibo de $concepto...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('No se pudo descargar el recibo. Razón: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Comprobantes de Pago',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _recibos.isEmpty
                  ? const Center(child: Text('No tienes comprobantes disponibles.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _recibos.length,
                      itemBuilder: (context, index) {
                        final item = _recibos[index];
                        final concepto = item['concepto'] ?? 'Pago sin concepto';
                        final monto = item['montoPagado'] ?? 0;
                        final fecha = item['fechaPago'] ?? '-';
                        final nroRecibo = item['numeroRecibo'] ?? '';
                        final idPago = item['idPago']; // Ahora sí tenemos idPago real

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.receipt_long, color: Colors.green),
                            ),
                            title: Text(concepto, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Recibo: $nroRecibo\nMonto: $monto Bs.\nFecha: $fecha'),
                            trailing: idPago != null 
                              ? IconButton(
                                  icon: const Icon(Icons.download_rounded, color: Colors.blue),
                                  onPressed: () => _descargarRecibo(idPago, concepto),
                                  tooltip: 'Descargar Recibo',
                                )
                              : null,
                          ),
                        );
                      },
                    ),
    );
  }
}
