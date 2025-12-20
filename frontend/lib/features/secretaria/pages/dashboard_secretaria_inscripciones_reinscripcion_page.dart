import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../estudiante/controller/estudiante_controller.dart';
import '../../estudiante/models/estudiante_response.dart';
import '../../director/services/curso_service.dart';
import '../../director/models/curso.dart';
import '../services/inscripcion_service.dart';

class ReinscripcionPage extends StatefulWidget {
  const ReinscripcionPage({super.key});

  @override
  State<ReinscripcionPage> createState() => _ReinscripcionPageState();
}

class _ReinscripcionPageState extends State<ReinscripcionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<EstudianteResponseDTO> _estudiantesFiltrados = [];
  EstudianteResponseDTO? _estudianteSeleccionado;
  
  Curso? _cursoSeleccionado;
  List<Curso> _cursosDisponibles = [];
  bool _isLoadingCursos = false;
  bool _isProcessing = false;

  final CursoService _cursoService = CursoService();
  final InscripcionService _inscripcionService = InscripcionService();

  @override
  void initState() {
    super.initState();
    // Load students on init? Or search on demand? 
    // Loading all might be heavy if there are thousands. For now, let's load all as per controller logic.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstudianteController>().cargarEstudiantes();
    });
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    setState(() => _isLoadingCursos = true);
    try {
      final cursos = await _cursoService.listarCursos();
      setState(() {
        _cursosDisponibles = cursos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar cursos: $e')),
      );
    } finally {
      setState(() => _isLoadingCursos = false);
    }
  }

  void _filtrarEstudiantes(String query) {
    final todos = context.read<EstudianteController>().estudiantes;
    if (query.isEmpty) {
      setState(() => _estudiantesFiltrados = []);
      return;
    }
    setState(() {
      _estudiantesFiltrados = todos.where((e) {
        final nombreCompleto = '${e.nombres} ${e.apellidoPaterno} ${e.apellidoMaterno ?? ''}'.toLowerCase();
        final ci = e.ci.toLowerCase();
        return nombreCompleto.contains(query.toLowerCase()) || ci.contains(query.toLowerCase());
      }).take(10).toList(); // Limit suggestions
    });
  }

  void _seleccionarEstudiante(EstudianteResponseDTO est) {
    setState(() {
      _estudianteSeleccionado = est;
      _searchController.text = '${est.nombres} ${est.apellidoPaterno}';
      _estudiantesFiltrados = [];
    });
  }

  Future<void> _procesarReinscripcion() async {
    if (_estudianteSeleccionado == null || _cursoSeleccionado == null) return;

    setState(() => _isProcessing = true);
    try {
      await _inscripcionService.registrarInscripcion(
        _estudianteSeleccionado!.idEstudiante,
        _cursoSeleccionado!.idCurso,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Re-inscripción Exitosa!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text('Estudiante: ${_estudianteSeleccionado!.nombres} ${_estudianteSeleccionado!.apellidoPaterno}'),
              Text('Curso: ${_cursoSeleccionado!.gradoNombre} - ${_cursoSeleccionado!.paralelo}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _limpiarFormulario();
              },
              child: const Text('Nueva Re-inscripción'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/dashboard-secretaria/matriculados');
              },
              child: const Text('Ir a Matriculados'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _estudianteSeleccionado = null;
      _cursoSeleccionado = null;
      _searchController.clear();
      _estudiantesFiltrados = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EstudianteController>();

    return MainScaffold(
      title: 'Re-inscripción Estudiantes Antiguos',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BUSCADOR
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Buscar Estudiante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar por Nombre o CI',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: controller.cargando 
                            ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))) 
                            : IconButton(icon: const Icon(Icons.clear), onPressed: _limpiarFormulario),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: _filtrarEstudiantes,
                    ),
                    if (_estudiantesFiltrados.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                          color: Colors.white,
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _estudiantesFiltrados.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final est = _estudiantesFiltrados[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text(est.nombres[0])),
                              title: Text('${est.nombres} ${est.apellidoPaterno}'),
                              subtitle: Text('CI: ${est.ci}'),
                              onTap: () => _seleccionarEstudiante(est),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // DETALLES Y CURSO
            if (_estudianteSeleccionado != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('2. Confirmar Estudiante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                        title: Text('${_estudianteSeleccionado!.nombres} ${_estudianteSeleccionado!.apellidoPaterno} ${_estudianteSeleccionado!.apellidoMaterno ?? ''}', 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CI: ${_estudianteSeleccionado!.ci}'),
                            Text('Fecha Nac: ${_estudianteSeleccionado!.fechaNacimiento?.toIso8601String().split('T')[0] ?? "N/A"}'),
                            Text('Tutor: ${_estudianteSeleccionado!.nombrePadre ?? _estudianteSeleccionado!.nombreMadre ?? "No registrado"}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('3. Asignar Nuevo Curso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_isLoadingCursos)
                         const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<Curso>(
                          value: _cursoSeleccionado,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Seleccione el Curso y Gestión',
                            prefixIcon: Icon(Icons.school),
                          ),
                          items: _cursosDisponibles.map((curso) {
                            return DropdownMenuItem(
                              value: curso,
                              child: Text('${curso.gradoNombre} "${curso.paralelo}" - ${curso.turno}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _cursoSeleccionado = val);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _procesarReinscripcion,
                  icon: _isProcessing 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Icon(Icons.save),
                  label: Text(_isProcessing ? 'Procesando...' : 'Registrar Re-inscripción'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
