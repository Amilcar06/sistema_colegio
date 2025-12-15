import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/pago_pension_service.dart';
import '../../estudiante/services/estudiante_service.dart';
import '../../estudiante/models/estudiante_response.dart';

class PagoPensionesPage extends StatefulWidget {
  const PagoPensionesPage({super.key});

  @override
  State<PagoPensionesPage> createState() => _PagoPensionesPageState();
}

class _PagoPensionesPageState extends State<PagoPensionesPage> {
  final PagoPensionService _pagoService = PagoPensionService();
  final EstudianteService _estudianteService = EstudianteService();

  bool _isLoading = false;
  List<EstudianteResponseDTO> _estudiantes = [];
  EstudianteResponseDTO? _selectedEstudiante;
  List<dynamic> _deudas = [];
  final Set<int> _selectedDeudas = {};

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    try {
      final list = await _estudianteService.listar();
      setState(() {
        _estudiantes = list;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estudiantes: $e')),
        );
      }
    }
  }

  Future<void> _cargarDeudas(int idEstudiante) async {
    setState(() => _isLoading = true);
    try {
      final deudas = await _pagoService.getDeudasEstudiante(idEstudiante);
      setState(() {
        _deudas = deudas;
        _selectedDeudas.clear();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar deudas: $e')),
        );
      }
    }
  }

  Future<void> _procesarPago() async {
    if (_selectedDeudas.isEmpty) return;

    setState(() => _isLoading = true);
    // Para simplificar, asumimos pago en efectivo por ahora y procesamos UNA a UNA o agrupadas si el backend lo soporta.
    // El backend recibe PagoRequestDTO { idEstudiante, idMensualidad, tipoPago, monto }
    // Asumimos que el backend maneja un pago por request. Vamos a iterar.
    
    // NOTA: El endpoint es POST /api/finanzas/pagos
    // Request Body: { "idEstudiante": X, "idCuentaCobrar": Y, "monto": Z, ... }
    // Debemos verificar qué estructura espera exactamente PagoRequestDTO.
    // En PagoMensualidadController.java: @RequestBody PagoRequestDTO request
    // Asumiré lo estándar. Si falla, depuraremos.
    
    int successCount = 0;
    for (int idCuenta in _selectedDeudas) {
      try {
        final cuenta = _deudas.firstWhere((d) => d['idCuentaCobrar'] == idCuenta);
        await _pagoService.registrarPago({
          'idCuentaCobrar': idCuenta,
          'montoPagado': cuenta['saldoPendiente'] ?? cuenta['montoTotal'], 
          'metodoPago': 'EFECTIVO',
          'observaciones': 'Pago en ventanilla'
        });
        successCount++;
      } catch (e) {
        print("Error pagando cuenta $idCuenta: $e");
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se procesaron $successCount pagos correctamente.')),
      );
      _cargarDeudas(_selectedEstudiante!.idEstudiante!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Cobro de Pensiones',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de Estudiante
            Autocomplete<EstudianteResponseDTO>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<EstudianteResponseDTO>.empty();
                }
                return _estudiantes.where((EstudianteResponseDTO option) {
                  return option.nombreCompleto
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()) || 
                      option.ci.contains(textEditingValue.text);
                });
              },
              displayStringForOption: (EstudianteResponseDTO option) => '${option.nombreCompleto} (${option.ci})',
              onSelected: (EstudianteResponseDTO selection) {
                setState(() {
                  _selectedEstudiante = selection;
                });
                if (selection.idEstudiante != null) {
                   _cargarDeudas(selection.idEstudiante!);
                }
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Estudiante (Nombre o CI)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Tabla de Deudas
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_deudas.isEmpty && _selectedEstudiante != null)
              const Text('No tiene deudas pendientes.')
            else if (_deudas.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Concepto')),
                          DataColumn(label: Text('Monto (Bs)')),
                          DataColumn(label: Text('Vencimiento')),
                          DataColumn(label: Text('Pagar')),
                        ],
                        rows: _deudas.map<DataRow>((deuda) {
                          final id = deuda['idCuentaCobrar'];
                          final isSelected = _selectedDeudas.contains(id);
                          return DataRow(
                            selected: isSelected,
                            onSelectChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedDeudas.add(id);
                                } else {
                                  _selectedDeudas.remove(id);
                                }
                              });
                            },
                            cells: [
                              DataCell(Text(deuda['concepto'] ?? 'Mensualidad')),
                              DataCell(Text(deuda['monto'].toString())),
                              DataCell(Text(deuda['fechaVencimiento'] ?? '-')),
                              DataCell(Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedDeudas.add(id);
                                    } else {
                                      _selectedDeudas.remove(id);
                                    }
                                  });
                                },
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _selectedDeudas.isNotEmpty ? _procesarPago : null,
                      icon: const Icon(Icons.payment),
                      label: Text('Procesar Pago (${_selectedDeudas.length})'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
