import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/comunicado_service.dart';

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
      setState(() {
        _comunicados = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mis Comunicados',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comunicados.isEmpty
              ? const Center(child: Text('No hay comunicados recientes'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _comunicados.length,
                  itemBuilder: (ctx, index) {
                    final com = _comunicados[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: com['prioridad'] == 'ALTA' ? Colors.red : 
                                         com['tipoDestinatario'] == 'POR_CURSO' ? Colors.green : Colors.blue,
                          child: Icon(
                            com['tipoDestinatario'] == 'POR_CURSO' ? Icons.class_ : Icons.campaign, 
                            color: Colors.white
                          ),
                        ),
                        title: Text(com['titulo'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(com['contenido'] ?? ''),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Por: ${com['nombreAutor'] ?? 'Sistema'}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  com['fechaPublicacion'] != null 
                                    ? com['fechaPublicacion'].toString().split('T')[0] 
                                    : '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
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
}
