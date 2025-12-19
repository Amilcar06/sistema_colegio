import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import '../models/asignacion_docente_response.dart';

class DashboardProfesorComunicadosPage extends StatefulWidget {
  const DashboardProfesorComunicadosPage({super.key});

  @override
  State<DashboardProfesorComunicadosPage> createState() => _DashboardProfesorComunicadosPageState();
}

class _DashboardProfesorComunicadosPageState extends State<DashboardProfesorComunicadosPage> with SingleTickerProviderStateMixin {
  final ProfesorService _profesorService = ProfesorService();
  late TabController _tabController;
  
  // Data
  List<dynamic> _comunicadosRecibidos = [];
  List<AsignacionDocenteResponse> _cursos = [];
  bool _isLoading = false;

  // Compose Form
  AsignacionDocenteResponse? _cursoSeleccionado;
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  String _prioridad = 'MEDIA';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final comunicados = await _profesorService.getComunicados();
      final cursos = await _profesorService.getMisCursos();
      
      if (mounted) {
        setState(() {
          _comunicadosRecibidos = comunicados;
          _cursos = cursos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _enviarComunicado() async {
    if (_cursoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un curso')));
      return;
    }
    if (_tituloCtrl.text.isEmpty || _contenidoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete todos los campos')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final idCurso = _cursoSeleccionado!.idCurso;

      await _profesorService.enviarComunicado({
        'titulo': _tituloCtrl.text,
        'contenido': _contenidoCtrl.text,
        'prioridad': _prioridad,
        'tipoDestinatario': 'POR_CURSO', // Enums.TipoDestinatario.POR_CURSO
        'idReferencia': idCurso
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comunicado enviado')));
        _tituloCtrl.clear();
        _contenidoCtrl.clear();
        setState(() {
          _prioridad = 'MEDIA';
          _cursoSeleccionado = null;
          _isLoading = false;
        });
        _cargarDatos(); // Refresh list to see sent item if desired (logic depends backend)
        _tabController.animateTo(0); // Switch to list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Comunicados y Avisos',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.inbox), text: 'Buzón de Entrada'),
              Tab(icon: Icon(Icons.send), text: 'Redactar Nuevo'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInboxTab(),
                      _buildComposeTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInboxTab() {
    if (_comunicadosRecibidos.isEmpty) {
      return const Center(child: Text('No hay comunicados recibidos.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _comunicadosRecibidos.length,
      itemBuilder: (context, index) {
        final c = _comunicadosRecibidos[index];
        final prioridad = c['prioridad'] ?? 'BAJA';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Icon(
              Icons.warning_amber_rounded,
              color: _getPriorityColor(prioridad),
            ),
            title: Text(
              c['titulo'] ?? 'Sin título',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${c['fechaPublicacion']?.toString().substring(0, 10)} - ${c['nombreAutor'] ?? 'Dirección'}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(c['contenido'] ?? ''),
                    const SizedBox(height: 10),
                    if (c['tipoDestinatario'] == 'POR_CURSO')
                      const Text('Destino: Curso Específico', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String prioridad) {
    switch (prioridad) {
      case 'ALTA': return Colors.red;
      case 'MEDIA': return Colors.orange;
      default: return Colors.green;
    }
  }

  Widget _buildComposeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enviar aviso a un Curso',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (_cursos.isEmpty)
                 const Text('No tienes cursos asignados para enviar comunicados.', style: TextStyle(color: Colors.red)),

              DropdownButtonFormField<AsignacionDocenteResponse>(
                value: _cursoSeleccionado,
                isExpanded: true,
                hint: const Text('Seleccione Destinatario (Curso)'),
                items: _cursos.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text('${c.nombreCurso} - ${c.nombreMateria}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _cursoSeleccionado = v),
                decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.class_)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Asunto / Título',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _contenidoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mensaje',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _prioridad,
                items: ['BAJA', 'MEDIA', 'ALTA']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _prioridad = v!),
                decoration: const InputDecoration(
                  labelText: 'Nivel de Importancia',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: (_isLoading || _cursos.isEmpty) ? null : _enviarComunicado,
                icon: const Icon(Icons.send),
                label: Text(_isLoading ? 'Enviando...' : 'Publicar Comunicado'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
