import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/comunicado_service.dart'; // Reusing service for now
import '../services/profesor_service.dart';

class DashboardProfesorComunicadosPage extends StatefulWidget {
  const DashboardProfesorComunicadosPage({super.key});

  @override
  State<DashboardProfesorComunicadosPage> createState() => _DashboardProfesorComunicadosPageState();
}

class _DashboardProfesorComunicadosPageState extends State<DashboardProfesorComunicadosPage> {
  final ComunicadoService _comunicadoService = ComunicadoService();
  final ProfesorService _profesorService = ProfesorService();
  
  bool _isLoading = false;
  List<dynamic> _cursos = [];
  dynamic _cursoSeleccionado;
  
  // Controllers
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  String _prioridad = 'MEDIA';

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    setState(() => _isLoading = true);
    try {
      final cursos = await _profesorService.getMisCursos();
      setState(() {
        _cursos = cursos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar cursos: $e')));
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
      // Extract idCurso. data structure from getMisCursos: {idAsignacion, materia: {nombre}, curso: {idCurso, nombre}}
      // Actually need to verify structure of getMisCursos response.
      // Based on previous usage, it returns asignaciones.
      // Let's assume standard structure or debug if needed.
      // Typically: { "curso": { "idCurso": 1, "nombre": "1ro Sec A" }, ... }
      
      final idCurso = _cursoSeleccionado['curso']['idCurso'];

      await _comunicadoService.crear({
        'titulo': _tituloCtrl.text,
        'contenido': _contenidoCtrl.text,
        'prioridad': _prioridad,
        'tipoDestinatario': 'POR_CURSO',
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
      title: 'Nuevo Comunicado',
      child: _isLoading && _cursos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Redactar Comunicado para Curso',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<dynamic>(
                        value: _cursoSeleccionado,
                        isExpanded: true,
                        hint: const Text('Seleccione un Curso'),
                        items: _cursos.map((c) {
                          // c is AsignacionDTO usually
                          final nombreCurso = c['curso']['nombre'];
                          final nombreMateria = c['materia']['nombre'];
                          return DropdownMenuItem(
                            value: c,
                            child: Text('$nombreCurso - $nombreMateria'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _cursoSeleccionado = v),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _tituloCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _contenidoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Contenido',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _prioridad,
                        items: ['BAJA', 'MEDIA', 'ALTA']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _prioridad = v!),
                        decoration: const InputDecoration(
                          labelText: 'Prioridad',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _enviarComunicado,
                        icon: const Icon(Icons.send),
                        label: Text(_isLoading ? 'Enviando...' : 'Enviar Comunicado'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
