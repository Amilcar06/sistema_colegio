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
      // Sort by date (ascending for future events)
      data.sort((a, b) {
        final da = DateTime.tryParse(a.fechaInicio) ?? DateTime.now();
        final db = DateTime.tryParse(b.fechaInicio) ?? DateTime.now();
        return da.compareTo(db);
      });

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
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _eventos.length,
                  itemBuilder: (ctx, index) {
                    final ev = _eventos[index];
                    
                    // Parse date
                    final date = DateTime.tryParse(ev.fechaInicio) ?? DateTime.now();
                    
                    final day = date.day.toString();
                    final month = _getMonthName(date.month);
                    final year = date.year.toString();

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Column
                        Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 16, bottom: 24),
                          child: Column(
                            children: [
                              Text(day, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text(month, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text(year, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        // Content Column
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(ev.tipoEvento, 
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(ev.titulo, 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                
                                if (ev.descripcion.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(ev.descripcion, 
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 3, overflow: TextOverflow.ellipsis),
                                ],

                                if (ev.ubicacion.isNotEmpty) ...[
                                   const SizedBox(height: 8),
                                   Row(
                                     children: [
                                       const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                       const SizedBox(width: 4),
                                       Expanded(child: Text(ev.ubicacion, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                     ],
                                   )
                                ]
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hay eventos próximos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
