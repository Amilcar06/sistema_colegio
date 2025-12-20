import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../estudiante/services/pago_service.dart';
import '../../shared/services/pdf_service.dart';

class HistorialTransaccionesPage extends StatefulWidget {
  const HistorialTransaccionesPage({super.key});

  @override
  State<HistorialTransaccionesPage> createState() => _HistorialTransaccionesPageState();
}

class _HistorialTransaccionesPageState extends State<HistorialTransaccionesPage> {
  final PagoService _pagoService = PagoService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _pagos = [];
  List<dynamic> _pagosFiltrados = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Load all payments initially (or last 50)
      // If the list is huge, we should paginate. Assuming manageable size for now.
      final pagos = await _pagoService.listarPagos();
      setState(() {
        _pagos = pagos;
        _pagosFiltrados = pagos;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrar(String query) {
    if (query.isEmpty) {
      setState(() => _pagosFiltrados = _pagos);
      return;
    }
    
    setState(() {
      _pagosFiltrados = _pagos.where((p) {
        final concepto = (p['idCuentaCobrar'] ?? '').toString(); // Ideally backend sends concept name
        // Backend DTO might be simple. Let's check response structure if needed.
        // Assuming backend sends some details. If not, we filter by ID or Amount.
        // Actually PagoResponseDTO has 'idPago', 'montoPagado', 'fechaPago', 'metodoPago', 'nombreCajero'.
        // It does not seem to include Student Name directly unless modified.
        // Let's filter by Cajero or ID for now.
        final metodo = (p['metodoPago'] ?? '').toString().toLowerCase();
        final cajero = (p['nombreCajero'] ?? '').toString().toLowerCase();
        
        return metodo.contains(query.toLowerCase()) || 
               cajero.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Historial de Transacciones',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Cajero o Método',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filtrar,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _pagosFiltrados.isEmpty
                        ? const Center(child: Text('No se encontraron transacciones.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _pagosFiltrados.length,
                            itemBuilder: (context, index) {
                              final pago = _pagosFiltrados[index];
                              final fecha = DateTime.tryParse(pago['fechaPago'] ?? '');
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    child: const Icon(Icons.attach_money, color: Colors.green),
                                  ),
                                  title: Text('Monto: Bs ${pago['montoPagado']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Método: ${pago['metodoPago']}'),
                                      Text('Cajero: ${pago['nombreCajero'] ?? "N/A"}'),
                                      if (fecha != null)
                                        Text(DateFormat('dd/MM/yyyy HH:mm').format(fecha), style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.print),
                                      onPressed: () async {
                                        try {
                                          await PdfService.descargarRecibo(pago['idPago']);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text('Error al descargar recibo: $e'),
                                              backgroundColor: Colors.red));
                                        }
                                      },
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
