import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../estudiante/controller/estudiante_controller.dart';
import '../../estudiante/models/estudiante_response.dart';
import '../../estudiante/services/pago_service.dart';

class CobrarPensionPage extends StatefulWidget {
  const CobrarPensionPage({super.key});

  @override
  State<CobrarPensionPage> createState() => _CobrarPensionPageState();
}

class _CobrarPensionPageState extends State<CobrarPensionPage> {
  final TextEditingController _searchController = TextEditingController();
  final PagoService _pagoService = PagoService();
  
  List<EstudianteResponseDTO> _estudiantesSugestiones = [];
  EstudianteResponseDTO? _estudianteSeleccionado;
  
  List<dynamic> _cuentasPorCobrar = [];
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
    });

    try {
      final deudas = await _pagoService.listarDeudas(est.idEstudiante);
      setState(() {
        _cuentasPorCobrar = deudas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar deudas: $e')));
    } finally {
      setState(() => _isLoadingDeudas = false);
    }
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
                      _cuentasPorCobrar = [];
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
            else if (_estudianteSeleccionado != null)
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Cuentas por Cobrar: ${_estudianteSeleccionado!.nombres} ${_estudianteSeleccionado!.apellidoPaterno}',
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(height: 10),
                     if (_cuentasPorCobrar.isEmpty)
                       const Center(child: Text('No tiene deudas pendientes.'))
                     else
                       Expanded(
                         child: ListView.builder(
                           itemCount: _cuentasPorCobrar.length,
                           itemBuilder: (context, index) {
                             final cuenta = _cuentasPorCobrar[index];
                             final saldo = (cuenta['montoTotal'] ?? 0.0) - (cuenta['montoPagado'] ?? 0.0);
                             final estado = cuenta['estado'] ?? 'PENDIENTE';
                             
                             return Card(
                               color: estado == 'PAGADO' ? Colors.green.shade50 : Colors.orange.shade50,
                               child: ListTile(
                                 title: Text(cuenta['concepto'] ?? 'Sin concepto'),
                                 subtitle: Text('Total: Bs ${cuenta['montoTotal']} - Pagado: Bs ${cuenta['montoPagado']}'),
                                 trailing: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Text('Saldo: Bs $saldo', style: const TextStyle(fontWeight: FontWeight.bold)),
                                     const SizedBox(width: 8),
                                     if (saldo > 0)
                                       FilledButton(
                                         onPressed: _isPaying ? null : () => _mostrarDialogoPago(cuenta),
                                         child: const Text('Cobrar'),
                                       )
                                     else
                                       const Icon(Icons.check_circle, color: Colors.green),
                                   ],
                                 ),
                               ),
                             );
                           },
                         ),
                       ),
                   ],
                 ),
               ),
          ],
        ),
      ),
    );
  }
}
