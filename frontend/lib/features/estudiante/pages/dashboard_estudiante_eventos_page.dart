import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/evento_service.dart';

class DashboardEstudianteEventosPage extends StatefulWidget {
  const DashboardEstudianteEventosPage({super.key});

  @override
  State<DashboardEstudianteEventosPage> createState() => _DashboardEstudianteEventosPageState();
}

class _DashboardEstudianteEventosPageState extends State<DashboardEstudianteEventosPage> {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Agenda Escolar',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _eventos.isEmpty
              ? const Center(child: Text('No hay eventos próximos'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _eventos.length,
                  itemBuilder: (ctx, index) {
                    final ev = _eventos[index];
                    String fechaStr = ev['fechaInicio'] is List 
                        ? '${ev['fechaInicio'][0]}-${ev['fechaInicio'][1]}-${ev['fechaInicio'][2]}' 
                        : ev['fechaInicio'].toString();
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.event_available, size: 40, color: Colors.indigo),
                        title: Text(ev['titulo'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${ev['tipoEvento']} | $fechaStr'),
                            if (ev['descripcion'] != null && ev['descripcion'].toString().isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Text(ev['descripcion'], maxLines: 2, overflow: TextOverflow.ellipsis),
                               ),
                             if (ev['ubicacion'] != null && ev['ubicacion'].toString().isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Row(
                                   children: [
                                     const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                     const SizedBox(width: 4),
                                     Text(ev['ubicacion'], style: const TextStyle(fontSize: 12)),
                                   ],
                                 ),
                               ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
