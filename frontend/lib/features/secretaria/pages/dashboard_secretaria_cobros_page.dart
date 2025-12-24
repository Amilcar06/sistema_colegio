import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../estudiante/controller/estudiante_controller.dart';
import '../../estudiante/models/estudiante_response.dart';
import '../../estudiante/services/pago_service.dart';
import '../../finanzas/services/finanzas_service.dart';
import '../../finanzas/models/estado_cuenta.dart';
import '../../finanzas/ui/widgets/payment_status_grid.dart';

class CobrarPensionPage extends StatefulWidget {
  const CobrarPensionPage({super.key});

  @override
  State<CobrarPensionPage> createState() => _CobrarPensionPageState();
}

class _CobrarPensionPageState extends State<CobrarPensionPage> {
  final TextEditingController _searchController = TextEditingController();
  final PagoService _pagoService = PagoService();
  final FinanzasService _finanzasService = FinanzasService();
  
  List<EstudianteResponseDTO> _estudiantesSugestiones = [];
  EstudianteResponseDTO? _estudianteSeleccionado;
  
  // List<dynamic> _cuentasPorCobrar = []; // Replaced by EstadoCuenta
  EstadoCuenta? _estadoCuenta;

  bool _isLoadingDeudas = false;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstudianteController>().cargarEstudiantes();
    });
  }

  void _filtrarEstudiantes(String query) {
    if (query.isEmpty) {
      setState(() => _estudiantesSugestiones = []);
      return;
    }
    final todos = context.read<EstudianteController>().estudiantes;
    setState(() {
      _estudiantesSugestiones = todos.where((e) {
        final nombre = '${e.nombres} ${e.apellidoPaterno}'.toLowerCase();
        final ci = e.ci.toLowerCase();
        return nombre.contains(query.toLowerCase()) || ci.contains(query.toLowerCase());
      }).take(5).toList();
    });
  }

  Future<void> _seleccionarEstudiante(EstudianteResponseDTO est) async {
    setState(() {
      _estudianteSeleccionado = est;
      _searchController.text = '${est.nombres} ${est.apellidoPaterno}';
      _estudiantesSugestiones = [];
      _isLoadingDeudas = true;
      _estadoCuenta = null;
    });

    try {
      final estado = await _finanzasService.getEstadoCuenta(est.idEstudiante);
      setState(() {
        _estadoCuenta = estado;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar deudas: $e')));
    } finally {
      setState(() => _isLoadingDeudas = false);
    }
  }

  void _mostrarDialogoPagoDesdeItem(ItemEstadoCuenta item) {
    if (item.estado == 'PAGADO') return;

    final map = {
      'idCuentaCobrar': item.idCuentaCobrar,
      'concepto': item.concepto,
      'montoTotal': item.monto,
      'montoPagado': item.monto - item.saldoPendiente,
      'estado': item.estado,
    };
    _mostrarDialogoPago(map);
  }

  void _mostrarDialogoPago(Map<String, dynamic> cuenta) {
    final saldo = (cuenta['montoTotal'] ?? 0.0) - (cuenta['montoPagado'] ?? 0.0);
    final montoController = TextEditingController(text: saldo.toString());
    String metodoPago = 'EFECTIVO';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Realizar Cobro'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Concepto: ${cuenta['concepto']}'),
              Text('Saldo Pendiente: Bs $saldo'),
              const SizedBox(height: 16),
              TextFormField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto a Pagar (Bs)'),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Monto inválido';
                  if (val > saldo) return 'Excede el saldo pendiente';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: metodoPago,
                items: const [
                  DropdownMenuItem(value: 'EFECTIVO', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'QR', child: Text('QR / Transferencia')),
                ],
                onChanged: (v) => metodoPago = v!,
                decoration: const InputDecoration(labelText: 'Método de Pago'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              Navigator.pop(context); // Close dialog
              await _procesarPago(cuenta['idCuentaCobrar'], double.parse(montoController.text), metodoPago);
            }, 
            child: const Text('Cobrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarPago(int idCuenta, double monto, String metodo) async {
    setState(() => _isPaying = true);
    try {
      await _pagoService.registrarPago(
        idCuentaCobrar: idCuenta,
        monto: monto,
        metodoPago: metodo,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado exitosamente'), backgroundColor: Colors.green),
      );
      
      // Reload debts
      if (_estudianteSeleccionado != null) {
        _seleccionarEstudiante(_estudianteSeleccionado!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cobrar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Caja y Cobros',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             // BUSCADOR
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Estudiante por Nombre o CI',
                prefixIcon: const Icon(Icons.person_search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _estudianteSeleccionado = null;
                      _estadoCuenta = null;
                      _estudiantesSugestiones = [];
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filtrarEstudiantes,
            ),
            
            if (_estudiantesSugestiones.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                 child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _estudiantesSugestiones.length,
                  itemBuilder: (_, index) {
                    final est = _estudiantesSugestiones[index];
                    return ListTile(
                      title: Text('${est.nombres} ${est.apellidoPaterno}'),
                      subtitle: Text('CI: ${est.ci}'),
                      onTap: () => _seleccionarEstudiante(est),
                    );
                  },
                ),
              ),
              
            const SizedBox(height: 20),
            
            if (_isLoadingDeudas)
               const Center(child: CircularProgressIndicator())
            else if (_estudianteSeleccionado != null && _estadoCuenta != null)
               Expanded(
                 child: SingleChildScrollView(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'Cuentas: ${_estudianteSeleccionado!.nombres} ${_estudianteSeleccionado!.apellidoPaterno}',
                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 20),
                       
                       // GRID DE MENSUALIDADES
                       PaymentStatusGrid(
                          mensualidades: _estadoCuenta!.mensualidades,
                          onMonthSelected: _mostrarDialogoPagoDesdeItem,
                       ),
                       
                       const SizedBox(height: 20),
                       if (_estadoCuenta!.extras.isNotEmpty) ...[
                         Text("Otros Pagos", style: Theme.of(context).textTheme.titleMedium),
                         const SizedBox(height: 10),
                         ..._estadoCuenta!.extras.map((item) {
                           final saldo = item.saldoPendiente;
                           return Card(
                             child: ListTile(
                               title: Text(item.concepto),
                               subtitle: Text('Saldo: Bs $saldo - Estado: ${item.estado}'),
                               trailing: saldo > 0 
                                  ? FilledButton(
                                      onPressed: () => _mostrarDialogoPagoDesdeItem(item),
                                      child: const Text('Cobrar'),
                                    )
                                  : const Icon(Icons.check_circle, color: Colors.green),
                             ),
                           );
                         }).toList(),
                       ],
                     ],
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}
