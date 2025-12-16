import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/pago_pension_service.dart';
import '../../estudiante/services/estudiante_service.dart';
import '../../estudiante/models/estudiante_response.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/pdf_util.dart';


class DashboardSecretariaComprobantesPage extends StatefulWidget {
  const DashboardSecretariaComprobantesPage({super.key});

  @override
  State<DashboardSecretariaComprobantesPage> createState() => _DashboardSecretariaComprobantesPageState();
}

class _DashboardSecretariaComprobantesPageState extends State<DashboardSecretariaComprobantesPage> {
  final PagoPensionService _pagoService = PagoPensionService();
  final EstudianteService _estudianteService = EstudianteService();

  bool _isLoading = false;
  List<EstudianteResponseDTO> _estudiantes = [];
  EstudianteResponseDTO? _selectedEstudiante;
  List<dynamic> _pagos = [];

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

  Future<void> _cargarPagos(int idEstudiante) async {
    setState(() => _isLoading = true);
    try {
      final pagos = await _pagoService.getPagos(idEstudiante: idEstudiante);
      setState(() {
        _pagos = pagos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar pagos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Comprobantes de Pago',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Buscador de Estudiante
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
                  _cargarPagos(selection.idEstudiante!);
                }
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Estudiante para ver Comprobantes',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Lista de Comprobantes
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_pagos.isEmpty && _selectedEstudiante != null)
              const Text('No se encontraron pagos registrados.')
            else if (_pagos.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _pagos.length,
                  itemBuilder: (context, index) {
                    final pago = _pagos[index];
                    final fecha = pago['fechaPago'] != null 
                        ? (pago['fechaPago'] is List 
                            ? '${pago['fechaPago'][2]}/${pago['fechaPago'][1]}/${pago['fechaPago'][0]}' // Si viene como array [2024, 12, 15]
                            : pago['fechaPago'].toString()) 
                        : '-';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.blue),
                        title: Text('Recibo: ${pago['numeroRecibo'] ?? 'S/N'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: $fecha'),
                            Text('Monto: Bs ${pago['montoPagado']} (${pago['metodoPago']})'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.print),
                          onPressed: () async {
                            try {
                              final pdfData = await _pagoService.descargarRecibo(pago['idPago']);
                              PdfUtil.descargarPdfWeb(pdfData, 'Recibo_${pago['numeroRecibo'] ?? pago['idPago']}.pdf');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al descargar recibo: $e')),
                              );
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
      ),
    );
  }
}
