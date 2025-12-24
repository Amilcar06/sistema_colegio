import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/curso_service.dart';
import '../../estudiante/models/estudiante_response.dart';
import '../../estudiante/services/estudiante_service.dart';
import '../services/inscripcion_service.dart';

class DashboardSecretariaInscripcionesPage extends StatefulWidget {
  const DashboardSecretariaInscripcionesPage({super.key});

  @override
  State<DashboardSecretariaInscripcionesPage> createState() =>
      _DashboardSecretariaInscripcionesPageState();
}

class _DashboardSecretariaInscripcionesPageState
    extends State<DashboardSecretariaInscripcionesPage> {
  final EstudianteService _estudianteService = EstudianteService();
  final CursoService _cursoService = CursoService();
  final InscripcionService _inscripcionService = InscripcionService();

  // Removed _estudiantes list (full list)
  List<dynamic> _cursos = [];
  List<dynamic> _inscripciones = [];
  List<EstudianteResponseDTO> _searchResults = [];

  EstudianteResponseDTO? _selectedEstudiante;
  int? _selectedCursoId;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  final int _gestionActual = 2025; 

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final cursos = await _cursoService.listarCursos(_gestionActual);
      
      setState(() {
        _cursos = cursos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cursos: $e')),
        );
      }
    }
  }

  Future<void> _buscarEstudiante() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _selectedEstudiante = null;
      _searchResults = [];
    });

    try {
      // Logic: Use buscarPorCI. If backend supports name search in same endpoint, great.
      // If not, this is strictly CI search.
      final results = await _estudianteService.buscarPorCI(query);
      setState(() {
        _searchResults = results;
      });
      if (results.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontraron estudiantes')));
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al buscar: $e')));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _registrarInscripcion() async {
    if (_selectedEstudiante == null || _selectedCursoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione estudiante y curso')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nuevaInscripcion = await _inscripcionService.registrarInscripcion(
        _selectedEstudiante!.idEstudiante!,
        _selectedCursoId!,
      );

      setState(() {
        _inscripciones.insert(0, nuevaInscripcion);
        _selectedEstudiante = null;
        _selectedCursoId = null;
        _searchResults = []; // Clear search results after success
        _searchController.clear();
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscripción registrada correctamente')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Gestión de Inscripciones',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Formulario de Inscripción ---
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registrar Nueva Inscripción',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          
                          // Search Section
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    labelText: 'Buscar Estudiante por CI',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person_search),
                                  ),
                                  onSubmitted: (_) => _buscarEstudiante(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: _isSearching ? null : _buscarEstudiante, 
                                icon: _isSearching 
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.search),
                              )
                            ],
                          ),
                          
                          // Results List (if searching or results found)
                          if (_searchResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                separatorBuilder: (_,__) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final est = _searchResults[index];
                                  return ListTile(
                                    title: Text(est.nombreCompleto),
                                    subtitle: Text('CI: ${est.ci}'),
                                    onTap: () {
                                      setState(() {
                                        _selectedEstudiante = est;
                                        _searchResults = []; // Hide list after selection
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                          if (_selectedEstudiante != null)
                             Padding(
                               padding: const EdgeInsets.symmetric(vertical: 12.0),
                               child: Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                                 child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text("Seleccionado: ${_selectedEstudiante!.nombreCompleto}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                                      IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _selectedEstudiante = null))
                                    ],
                                 ),
                               ),
                             ),

                          const SizedBox(height: 20),

                          // Selector de Curso
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Curso',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.class_),
                            ),
                            value: _selectedCursoId,
                              items: _cursos.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.idCurso, 
                                  child: Text("${c.nombreGrado} ${c.paralelo}"),
                                );
                              }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedCursoId = val);
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: (_isSaving || _selectedEstudiante == null) ? null : _registrarInscripcion,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.save),
                              label: Text(_isSaving ? 'Registrando...' : 'Registrar Inscripción'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // --- Lista de Inscripciones Recientes ---
                  if (_inscripciones.isNotEmpty) ...[
                     const Text(
                      'Inscripciones Recientes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _inscripciones.length,
                      itemBuilder: (context, index) {
                        final ins = _inscripciones[index];
                        // Ajustar campos segun respuesta del backend
                        final nombreEst = ins['nombreEstudiante'] ?? 'Estudiante'; 
                        final curso = ins['nombreCurso'] ?? 'Curso';
                        final fecha = ins['fechaInscripcion'] ?? 'Fecha';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(nombreEst),
                            subtitle: Text("Curso: $curso \nFecha: $fecha"),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
    );
  }
}
