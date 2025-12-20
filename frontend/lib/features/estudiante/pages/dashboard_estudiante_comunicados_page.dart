import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/comunicado_service.dart';
import 'package:intl/intl.dart';

class DashboardEstudianteComunicadosPage extends StatefulWidget {
  const DashboardEstudianteComunicadosPage({super.key});

  @override
  State<DashboardEstudianteComunicadosPage> createState() => _DashboardEstudianteComunicadosPageState();
}

class _DashboardEstudianteComunicadosPageState extends State<DashboardEstudianteComunicadosPage> {
  final ComunicadoService _service = ComunicadoService();
  bool _isLoading = false;
  List<dynamic> _comunicados = [];

  @override
  void initState() {
    super.initState();
    _cargarComunicados();
  }

  Future<void> _cargarComunicados() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.listar();
      // Ordenar por fecha descendente si no viene ordenado
      data.sort((a, b) {
        final fa = a.fechaPublicacion;
        final fb = b.fechaPublicacion;
        return fb.compareTo(fa);
      });
      
      setState(() {
        _comunicados = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getPriorityColor(String prioridad) {
    switch (prioridad) {
      case 'ALTA': return Colors.red;
      case 'MEDIA': return Colors.orange;
      case 'BAJA': return Colors.green;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Avisos y Comunicados',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comunicados.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _comunicados.length,
                  itemBuilder: (ctx, index) {
                    final com = _comunicados[index];
                    final prioridad = com.prioridad;
                    final tipo = com.tipoDestinatario; // GENERAL, POR_CURSO
                    final fecha = com.fechaPublicacion.isNotEmpty 
                        ? com.fechaPublicacion.split('T')[0] 
                        : '';
                        
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                        border: Border(left: BorderSide(color: _getPriorityColor(prioridad), width: 6)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(tipo == 'POR_CURSO' ? 'MI CURSO' : 'GENERAL', 
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                  backgroundColor: tipo == 'POR_CURSO' ? Colors.teal : Colors.indigo,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.all(0),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                Text(fecha, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(com.titulo, 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 8),
                            Text(com.contenido, 
                              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
                            const SizedBox(height: 12),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Publicado por: ${com.nombreAutor}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hay comunicados recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
