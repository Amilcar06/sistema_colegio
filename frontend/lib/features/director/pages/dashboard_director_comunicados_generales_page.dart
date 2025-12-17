import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/comunicado_service.dart';
import 'package:intl/intl.dart';

class DashboardDirectorComunicadosGeneralesPage extends StatefulWidget {
  const DashboardDirectorComunicadosGeneralesPage({super.key});

  @override
  State<DashboardDirectorComunicadosGeneralesPage> createState() => _DashboardDirectorComunicadosGeneralesPageState();
}

class _DashboardDirectorComunicadosGeneralesPageState extends State<DashboardDirectorComunicadosGeneralesPage> {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _crearComunicado(Map<String, dynamic> data) async {
    try {
      await _service.crear(data);
      _cargarComunicados();
      if (mounted) {
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comunicado publicado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
      }
    }
  }

  void _mostrarDialogoCrear() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String prioridad = 'MEDIA';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Comunicado General'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: prioridad,
              items: ['BAJA', 'MEDIA', 'ALTA']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => prioridad = v!,
              decoration: const InputDecoration(labelText: 'Prioridad'),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
              _crearComunicado({
                'titulo': titleCtrl.text,
                'contenido': contentCtrl.text,
                'prioridad': prioridad,
                'tipoDestinatario': 'TODOS', // Global
                'idReferencia': null
              });
            },
            child: const Text('Publicar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Comunicados Generales',
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrear,
        child: const Icon(Icons.add),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _comunicados.length,
              itemBuilder: (ctx, index) {
                final com = _comunicados[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: com['prioridad'] == 'ALTA' ? Colors.red : Colors.blue,
                      child: const Icon(Icons.campaign, color: Colors.white),
                    ),
                    title: Text(com['titulo'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(com['contenido'] ?? ''),
                        Text(
                          'Por: ${com['nombreAutor'] ?? 'Anon'} - ${com['fechaPublicacion'] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
