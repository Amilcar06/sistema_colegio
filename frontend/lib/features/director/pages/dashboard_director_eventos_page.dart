import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/evento_service.dart';
import 'package:intl/intl.dart';

class DashboardDirectorEventosPage extends StatefulWidget {
  const DashboardDirectorEventosPage({super.key});

  @override
  State<DashboardDirectorEventosPage> createState() => _DashboardDirectorEventosPageState();
}

class _DashboardDirectorEventosPageState extends State<DashboardDirectorEventosPage> {
  final EventoService _service = EventoService();
  bool _isLoading = false;
  List<dynamic> _eventos = [];

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.listar();
      setState(() {
        _eventos = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _crearEvento(Map<String, dynamic> data) async {
    try {
      await _service.crear(data);
      _cargarEventos();
      if (mounted) {
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento creado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear: $e')));
      }
    }
  }

  void _mostrarDialogoCrear() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    
    DateTime fechaInicio = DateTime.now();
    DateTime fechaFin = DateTime.now().add(const Duration(hours: 2));
    String tipo = 'ACTO_CIVICO';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: const Text('Nuevo Evento Académico'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                TextField(
                  controller: ubicacionCtrl,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: tipo,
                  items: ['FERIADO', 'EXAMEN', 'ACTO_CIVICO', 'REUNION', 'OTRO']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setStateBuilder(() => tipo = v!),
                  decoration: const InputDecoration(labelText: 'Tipo de Evento'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text('Inicio: ${DateFormat('yyyy-MM-dd HH:mm').format(fechaInicio)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fechaInicio,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setStateBuilder(() => fechaInicio = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                // Formatear fechas a ISO string para el backend si es necesario, o enviar objeto date
                // Asumimos backend acepta ISO string
                _crearEvento({
                  'titulo': titleCtrl.text,
                  'descripcion': descCtrl.text,
                  'ubicacion': ubicacionCtrl.text,
                  'fechaInicio': fechaInicio.toIso8601String(),
                  'fechaFin': fechaFin.toIso8601String(), // Simplificado: misma fecha + 2h
                  'tipoEvento': tipo
                });
              },
              child: const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Agenda de Eventos',
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrear,
        child: const Icon(Icons.add),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _eventos.length,
              itemBuilder: (ctx, index) {
                final ev = _eventos[index];
                // Handle different date formats or list structures
                String fechaStr = ev['fechaInicio'] is List 
                    ? '${ev['fechaInicio'][0]}-${ev['fechaInicio'][1]}-${ev['fechaInicio'][2]}' 
                    : ev['fechaInicio'].toString();
                    
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event, size: 40, color: Colors.orange),
                    title: Text(ev['titulo'] ?? ''),
                    subtitle: Text('${ev['tipoEvento']} | $fechaStr\n${ev['descripcion'] ?? ''}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
