import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import '../models/boletin_notas_model.dart';

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

  @override
  void initState() {
    super.initState();
    _cargarBoletin();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notas guardadas correctamente')),
        );
      }
      // Recargar para confirmar persistencia
      _cargarBoletin();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
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
    return MainScaffold(
      title: 'Registro de Notas',
      child: Column(
        children: [
          // Header: Selector Trimestre y Boton Guardar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _trimestreSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Trimestre',
                      border: OutlineInputBorder(),
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _guardarTodo,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                       DataColumn(label: Text('Estudiante')),
                       DataColumn(label: Text('Ser (10)')),
                       DataColumn(label: Text('Saber (35)')),
                       DataColumn(label: Text('Hacer (35)')),
                       DataColumn(label: Text('Decidir (10)')),
                       DataColumn(label: Text('Auto (10)')),
                       DataColumn(label: Text('Final', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _estudiantes.map((e) {
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 150, child: Text(e.nombreEstudiante))),
                        _buildInputCell(e, (val) => e.ser = val, e.ser, 10),
                        _buildInputCell(e, (val) => e.saber = val, e.saber, 35),
                        _buildInputCell(e, (val) => e.hacer = val, e.hacer, 35),
                        _buildInputCell(e, (val) => e.decidir = val, e.decidir, 10),
                        _buildInputCell(e, (val) => e.autoevaluacion = val, e.autoevaluacion, 10),
                        DataCell(Text(e.notaFinal.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  DataCell _buildInputCell(BoletinNotasModel model, Function(double) onChanged, double currentValue, double max) {
    return DataCell(
      SizedBox(
        width: 60,
        child: TextFormField(
          initialValue: currentValue == 0 ? '' : currentValue.toString(), // Empty if 0 for easier typing
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
             hintText: '0', 
             border: InputBorder.none,
             isDense: true,
          ),
          onChanged: (val) {
            double? v = double.tryParse(val);
            if (v != null) {
              if (v > max) v = max; // Clamp max
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
