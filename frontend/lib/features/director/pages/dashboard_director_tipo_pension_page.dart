import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/tipo_pension_service.dart';

class DashboardDirectorTipoPensionPage extends StatefulWidget {
  const DashboardDirectorTipoPensionPage({super.key});

  @override
  State<DashboardDirectorTipoPensionPage> createState() => _DashboardDirectorTipoPensionPageState();
}

class _DashboardDirectorTipoPensionPageState extends State<DashboardDirectorTipoPensionPage> {
  final TipoPensionService _service = TipoPensionService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tiposPago = [];

  // TODO: Obtener dinmicamente la gestin activa. Por ahora usamos 1.
  final int _idGestion = 1;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final datos = await _service.getTiposPension(_idGestion);
      setState(() {
        _tiposPago = datos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _eliminar(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este concepto de pago?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.eliminarTipoPension(id);
        _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eliminado correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (context) => _TipoPagoFormDialog(
        item: item,
        idGestion: _idGestion,
        onSave: _cargarDatos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Gestión de Conceptos de Pago',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Conceptos de Pago (Gestión 2025)',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => _mostrarFormulario(),
                              icon: const Icon(Icons.add),
                              label: const Text('Nuevo Concepto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Conceptos de Pago (Gestión 2025)',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _mostrarFormulario(),
                              icon: const Icon(Icons.add),
                              label: const Text('Nuevo Concepto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Monto (Bs)')),
                          DataColumn(label: Text('Fecha Límite')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: _tiposPago.map((e) {
                          return DataRow(cells: [
                            DataCell(Text(e['nombre'] ?? '')),
                            DataCell(Text(e['montoDefecto']?.toString() ?? '0.00')),
                            DataCell(Text(e['fechaLimite'] ?? 'Sin fecha')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _mostrarFormulario(item: e),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _eliminar(e['idTipoPago']),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TipoPagoFormDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  final int idGestion;
  final VoidCallback onSave;

  const _TipoPagoFormDialog({this.item, required this.idGestion, required this.onSave});

  @override
  State<_TipoPagoFormDialog> createState() => _TipoPagoFormDialogState();
}

class _TipoPagoFormDialogState extends State<_TipoPagoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController(); // YYYY-MM-DD
  final TipoPensionService _service = TipoPensionService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nombreCtrl.text = widget.item!['nombre'];
      _montoCtrl.text = widget.item!['montoDefecto'].toString();
      _fechaCtrl.text = widget.item!['fechaLimite'] ?? '';
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final data = {
      'nombre': _nombreCtrl.text,
      'montoDefecto': double.parse(_montoCtrl.text),
      'fechaLimite': _fechaCtrl.text.isEmpty ? null : _fechaCtrl.text,
      'idGestion': widget.idGestion,
    };

    try {
      if (widget.item == null) {
        await _service.crearTipoPension(data);
      } else {
        await _service.actualizarTipoPension(widget.item!['idTipoPago'], data);
      }
      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Nuevo Concepto' : 'Editar Concepto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(labelText: 'Monto (Bs)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _fechaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fecha Límite (YYYY-MM-DD)',
                  hintText: 'Ej. 2025-03-10',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          child: Text(_saving ? 'Guardando...' : 'Guardar'),
        ),
      ],
    );
  }
}
