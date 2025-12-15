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

  List<EstudianteResponseDTO> _estudiantes = [];
  List<dynamic> _cursos = [];
  List<dynamic> _inscripciones = []; // Historial reciente o lista completa

  EstudianteResponseDTO? _selectedEstudiante;
  int? _selectedCursoId;
  bool _isLoading = false;
  bool _isSaving = false;

  final int _gestionActual = 2025; // TODO: Obtener del backend dinámicamente

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _estudianteService.listar(),
        _cursoService.listarCursos(_gestionActual),
      ]);

      setState(() {
        _estudiantes = futures[0] as List<EstudianteResponseDTO>;
        _cursos = futures[1] as List<dynamic>;
        _isLoading = false;
      });
      // Cargar inscripciones existentes si es necesario
      _cargarInscripciones(); 
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _cargarInscripciones() async {
    // Si tienes un endpoint para listar inscripciones recientes o todas
     try {
        // Asumiendo que tenemos un endpoint para listar por gestion.
        // Si no, podríamos mostrar solo las que acabamos de hacer localmente.
        // final lista = await _inscripcionService.listarPorGestion(1); 
        // setState(() => _inscripciones = lista);
     } catch(e) {
       // Silent fail or log
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
        _inscripciones.insert(0, nuevaInscripcion); // Agregar a la lista visual
        _selectedEstudiante = null; // Reset form
        _selectedCursoId = null;
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
                          // Buscador de Estudiante
                          Autocomplete<EstudianteResponseDTO>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<EstudianteResponseDTO>.empty();
                              }
                              return _estudiantes.where((EstudianteResponseDTO option) {
                                return option.nombreCompleto
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()) ||
                                    option.ci.contains(textEditingValue.text);
                              });
                            },
                            displayStringForOption: (EstudianteResponseDTO option) =>
                                '${option.nombreCompleto} (${option.ci})',
                            onSelected: (EstudianteResponseDTO selection) {
                              setState(() {
                                _selectedEstudiante = selection;
                              });
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              // Resetear controller si se limpió la selección manual
                              if (_selectedEstudiante == null && textEditingController.text.isNotEmpty) {
                                // Opional: lógica para limpiar
                              }
                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Buscar Estudiante (Nombre o CI)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_search),
                                ),
                              );
                            },
                          ),
                          if (_selectedEstudiante != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text("Seleccionado: ${_selectedEstudiante!.nombreCompleto}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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
                              onPressed: _isSaving ? null : _registrarInscripcion,
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
                  
                  // --- Lista de Inscripciones Recientes (Placeholder) ---
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
