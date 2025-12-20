import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../controller/evento_controller.dart';
import '../../comunicacion/models/evento.dart';

class DashboardDirectorEventosPage extends StatelessWidget {
  const DashboardDirectorEventosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventoController()..cargarEventos(),
      child: const _EventosView(),
    );
  }
}

class _EventosView extends StatefulWidget {
  const _EventosView();

  @override
  State<_EventosView> createState() => _EventosViewState();
}

class _EventosViewState extends State<_EventosView> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventoController>();

    return DefaultTabController(
      length: 2,
      child: MainScaffold(
        title: 'Agenda de Eventos',
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrarDialogo(context),
          label: const Text('Nuevo Evento'),
          icon: const Icon(Icons.add),
        ),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Próximos'),
            Tab(text: 'Historial'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
        child: TabBarView(
          children: [
            _EventosList(cargarHistorial: false),
            _EventosList(cargarHistorial: true),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EventoDialog(
        controller: context.read<EventoController>(),
      ),
    );
  }
}

class _EventosList extends StatefulWidget {
  final bool cargarHistorial;
  const _EventosList({required this.cargarHistorial});

  @override
  State<_EventosList> createState() => _EventosListState();
}

class _EventosListState extends State<_EventosList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cargarHistorial) {
        context.read<EventoController>().cargarHistorial();
      } else {
        context.read<EventoController>().cargarEventos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventoController>();

    if (controller.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.eventos.isEmpty) {
      return Center(
        child: Text(
          widget.cargarHistorial
              ? 'No hay eventos pasados.'
              : 'No hay eventos próximos.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.eventos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final ev = controller.eventos[index];
        return _buildEventoCard(context, ev); // Changed to static or moved method?
        // _buildEventoCard is in _EventosViewState. Needs refactoring.
        // Let's refactor _buildEventoCard to be a static method or standalone widget.
        // For simplicity, I will copy _buildEventoCard logic here or make the View State handle both.
      },
    );
  }



  Widget _buildEventoCard(BuildContext context, Evento ev) {
    final fecha = DateTime.tryParse(ev.fechaInicio);
    final dia = fecha != null ? DateFormat('dd').format(fecha) : '--';
    final mes = fecha != null ? DateFormat('MMM').format(fecha).toUpperCase() : '--';
    final colorTipo = _getColorTipo(ev.tipoEvento);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: colorTipo.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dia, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorTipo)),
                  Text(mes, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorTipo)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(ev.tipoEvento, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: colorTipo,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
                              onPressed: () => _mostrarDialogo(context, evento: ev),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _confirmarEliminacion(context, ev),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(ev.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (ev.ubicacion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(ev.ubicacion, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                    if (ev.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(ev.descripcion, style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'FERIADO': return Colors.red;
      case 'EXAMEN': return Colors.orange;
      case 'ACTO_CIVICO': return Colors.blue;
      case 'REUNION': return Colors.purple;
      default: return Colors.teal;
    }
  }

  void _mostrarDialogo(BuildContext context, {Evento? evento}) {
    showDialog(
      context: context,
      builder: (_) => _EventoDialog(
        controller: context.read<EventoController>(),
        evento: evento,
      ),
    );
  }

  Future<void> _confirmarEliminacion(BuildContext context, Evento ev) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: Text('¿Eliminar el evento "${ev.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<EventoController>().eliminarEvento(ev.idEvento);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
      }
    }
  }
}

class _EventoDialog extends StatefulWidget {
  final EventoController controller;
  final Evento? evento;

  const _EventoDialog({required this.controller, this.evento});

  @override
  State<_EventoDialog> createState() => _EventoDialogState();
}

class _EventoDialogState extends State<_EventoDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  
  DateTime _fechaInicio = DateTime.now();
  TimeOfDay _horaInicio = TimeOfDay.now();
  
  // ignore: unused_field
  DateTime _fechaFin = DateTime.now().add(const Duration(hours: 2));
  
  String _tipo = 'ACTO_CIVICO';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.evento != null) {
      _titleCtrl.text = widget.evento!.titulo;
      _descCtrl.text = widget.evento!.descripcion;
      _ubicacionCtrl.text = widget.evento!.ubicacion;
      _tipo = widget.evento!.tipoEvento;
      
      final fi = DateTime.tryParse(widget.evento!.fechaInicio);
      if (fi != null) {
        _fechaInicio = fi;
        _horaInicio = TimeOfDay.fromDateTime(fi);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.evento == null ? 'Nuevo Evento' : 'Editar Evento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ubicacionCtrl,
              decoration: const InputDecoration(labelText: 'Ubicación', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
              items: ['FERIADO', 'EXAMEN', 'ACTO_CIVICO', 'REUNION', 'OTRO']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd/MM/yyyy').format(_fechaInicio)),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(_horaInicio.format(context)),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.evento == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _fechaInicio = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _horaInicio);
    if (picked != null) setState(() => _horaInicio = picked);
  }

  Future<void> _guardar() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El título es obligatorio')));
      return;
    }

    setState(() => _saving = true);

    final fechaCompleta = DateTime(
      _fechaInicio.year, _fechaInicio.month, _fechaInicio.day,
      _horaInicio.hour, _horaInicio.minute
    );
    
    // Simple logic: End date is start date + 2 hours for now
    final fechaFin = fechaCompleta.add(const Duration(hours: 2));

    final data = {
      'titulo': _titleCtrl.text,
      'descripcion': _descCtrl.text,
      'ubicacion': _ubicacionCtrl.text,
      'tipoEvento': _tipo,
      'fechaInicio': fechaCompleta.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
    };

    bool exito;
    if (widget.evento == null) {
      exito = await widget.controller.crearEvento(data);
    } else {
      exito = await widget.controller.actualizarEvento(widget.evento!.idEvento, data);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.evento == null ? 'Evento creado' : 'Evento actualizado')),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.controller.errorMessage ?? 'Error')));
      }
    }
  }
}
