import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import '../models/boletin_notas_model.dart';
import 'dart:async';

class RegistroNotasPage extends StatefulWidget {
  final String idAsignacion;

  const RegistroNotasPage({super.key, required this.idAsignacion});

  @override
  State<RegistroNotasPage> createState() => _RegistroNotasPageState();
}

class _RegistroNotasPageState extends State<RegistroNotasPage> {
  final ProfesorService _service = ProfesorService();
  bool _isLoading = false;
  List<BoletinNotasModel> _estudiantes = [];
  String _trimestreSeleccionado = 'PRIMER'; // Default
  bool _isCardView = false; // Toggle for Mobile

  // Auto-save timer (not implemented logic yet, just placeholder for improve list)
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cargarBoletin();
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _cargarBoletin() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getBoletinCurso(int.parse(widget.idAsignacion), _trimestreSeleccionado);
      setState(() {
        _estudiantes = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar boletín: $e')),
        );
      }
    }
  }

  Future<void> _guardarTodo() async {
    setState(() => _isLoading = true);
    try {
      await _service.guardarNotasBatch(
          int.parse(widget.idAsignacion), _trimestreSeleccionado, _estudiantes);
      
      if (mounted) {
        // Confirmation Dialog/Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notas guardadas correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _cargarBoletin();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error al guardar'),
            content: Text(e.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
            ],
          ),
        );
      }
    }
  }

  void _recalcularNota(BoletinNotasModel modelo) {
    setState(() {
      modelo.notaFinal = modelo.ser + modelo.saber + modelo.hacer + modelo.decidir + modelo.autoevaluacion;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check screen width to auto-enable card view on small screens if desired
    // final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return MainScaffold(
      title: 'Registro de Notas',
      child: Column(
        children: [
          // Header: Selector Trimestre, Toggle View, Boton Guardar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _trimestreSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Trimestre',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        ),
                        items: ['PRIMER', 'SEGUNDO', 'TERCER']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _trimestreSeleccionado = val;
                            });
                            _cargarBoletin();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Toggle View Button
                    IconButton.outlined(
                      icon: Icon(_isCardView ? Icons.table_chart : Icons.view_agenda),
                      tooltip: _isCardView ? 'Ver Tabla' : 'Ver Tarjetas',
                      onPressed: () => setState(() => _isCardView = !_isCardView),
                      style: IconButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _guardarTodo,
                    icon: const Icon(Icons.save),
                    label: const Text('GUARDAR TODOS LOS CAMBIOS'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_estudiantes.isEmpty)
             const Expanded(child: Center(child: Text('No hay estudiantes inscritos.')))
          else
            Expanded(
              child: _isCardView ? _buildCardView() : _buildTableView(),
            ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
             DataColumn(label: Text('Estudiante', style: TextStyle(fontWeight: FontWeight.bold))),
             DataColumn(label: Text('Ser (10)')),
             DataColumn(label: Text('Saber (35)')),
             DataColumn(label: Text('Hacer (35)')),
             DataColumn(label: Text('Decidir (10)')),
             DataColumn(label: Text('Auto (10)')),
             DataColumn(label: Text('Final', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _estudiantes.map((e) {
            final isRisk = e.notaFinal < 51;
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>((states) {
                 if (isRisk) return Colors.red.shade50;
                 return null;
              }),
              cells: [
              DataCell(SizedBox(width: 150, child: Text(e.nombreEstudiante, style: const TextStyle(fontWeight: FontWeight.w500)))),
              _buildInputCell(e, (val) => e.ser = val, e.ser, 10),
              _buildInputCell(e, (val) => e.saber = val, e.saber, 35),
              _buildInputCell(e, (val) => e.hacer = val, e.hacer, 35),
              _buildInputCell(e, (val) => e.decidir = val, e.decidir, 10),
              _buildInputCell(e, (val) => e.autoevaluacion = val, e.autoevaluacion, 10),
              DataCell(Text(
                e.notaFinal.toStringAsFixed(0), 
                style: TextStyle(fontWeight: FontWeight.bold, color: isRisk ? Colors.red : Colors.black)
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _estudiantes.length,
      itemBuilder: (context, index) {
        final e = _estudiantes[index];
        final isRisk = e.notaFinal < 51;
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isRisk ? BorderSide(color: Colors.red.shade200, width: 1.5) : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(e.nombreEstudiante, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRisk ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Nota: ${e.notaFinal.toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isRisk ? Colors.red.shade800 : Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildCardInput('Ser', 10, e.ser, (v) { e.ser = v; _recalcularNota(e); }),
                    _buildCardInput('Saber', 35, e.saber, (v) { e.saber = v; _recalcularNota(e); }),
                    _buildCardInput('Hacer', 35, e.hacer, (v) { e.hacer = v; _recalcularNota(e); }),
                    _buildCardInput('Decidir', 10, e.decidir, (v) { e.decidir = v; _recalcularNota(e); }),
                    _buildCardInput('Auto', 10, e.autoevaluacion, (v) { e.autoevaluacion = v; _recalcularNota(e); }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardInput(String label, double max, double val, Function(double) onChanged) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        initialValue: val == 0 ? '' : val.toStringAsFixed(0),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$label /${max.toInt()}',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
        ),
        onChanged: (v) {
          final d = double.tryParse(v);
          if (d != null && d >= 0 && d <= max) {
            onChanged(d);
          } else if (v.isEmpty) {
            onChanged(0);
          }
        },
      ),
    );
  }

  DataCell _buildInputCell(BoletinNotasModel model, Function(double) onChanged, double currentValue, double max) {
    return DataCell(
      SizedBox(
        width: 60,
        child: TextFormField(
          initialValue: currentValue == 0 ? '' : currentValue.toStringAsFixed(0),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
             hintText: '0', 
             border: InputBorder.none,
             isDense: true,
          ),
          onChanged: (val) {
            double? v = double.tryParse(val);
            if (v != null) {
              if (v > max) v = max;
              if (v < 0) v = 0;
              onChanged(v);
              _recalcularNota(model);
            } else {
               if (val.isEmpty) {
                 onChanged(0);
                 _recalcularNota(model);
               }
            }
          },
        ),
      ),
    );
  }
}
