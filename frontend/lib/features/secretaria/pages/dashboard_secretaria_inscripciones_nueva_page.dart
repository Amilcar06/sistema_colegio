import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/registro_estudiante_form.dart';
import '../../estudiante/models/estudiante_response.dart';
import '../../director/services/curso_service.dart';
import '../../director/models/curso.dart';
import '../services/inscripcion_service.dart';

class NuevaInscripcionPage extends StatefulWidget {
  const NuevaInscripcionPage({super.key});

  @override
  State<NuevaInscripcionPage> createState() => _NuevaInscripcionPageState();
}

class _NuevaInscripcionPageState extends State<NuevaInscripcionPage> {
  int _currentStep = 0;
  EstudianteResponseDTO? _estudianteRegistrado;
  Curso? _cursoSeleccionado;
  
  final CursoService _cursoService = CursoService();
  final InscripcionService _inscripcionService = InscripcionService();
  
  List<Curso> _cursosDisponibles = [];
  bool _isLoadingCursos = false;
  bool _isEnrolling = false;

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    setState(() => _isLoadingCursos = true);
    try {
      final cursos = await _cursoService.listarCursos(); // Loads all courses
      // We might want to filter by current 'Gestion' if possible, or assume backend filters
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

  void _onEstudianteRegistrado(EstudianteResponseDTO estudiante) {
    setState(() {
      _estudianteRegistrado = estudiante;
      _currentStep = 1; // Move to next step
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estudiante registrado. Seleccione el curso.')),
    );
  }

  Future<void> _finalizarInscripcion() async {
    if (_estudianteRegistrado == null || _cursoSeleccionado == null) return;

    setState(() => _isEnrolling = true);
    try {
      await _inscripcionService.registrarInscripcion(
        _estudianteRegistrado!.idEstudiante,
        _cursoSeleccionado!.idCurso,
      );
      
      setState(() => _currentStep = 2); // Move to Success Step
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la inscripción: $e')),
      );
    } finally {
      setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Nueva Inscripción',
      child: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        controlsBuilder: (context, details) {
          // Hide default controls for Step 1 as the Form handles it
          if (_currentStep == 0) return const SizedBox.shrink();
          if (_currentStep == 2) return const SizedBox.shrink(); // Hide for success step too
          
          // Custom controls for Step 2
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: _isEnrolling ? null : _finalizarInscripcion,
                  icon: _isEnrolling 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Icon(Icons.check),
                  label: const Text('Confirmar Inscripción'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Atrás'),
                ),
              ],
            ),
          );
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          // STEP 1: REGISTRO ESTUDIANTE
          Step(
            title: const Text('Estudiante'),
            content: SizedBox(
              height: 600, // Fixed height for form scrolling
              child: RegistroEstudianteForm(
                onSuccess: _onEstudianteRegistrado,
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
          ),
          
          // STEP 2: SELECCIÓN CURSO
          Step(
            title: const Text('Curso'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_estudianteRegistrado != null)
                  Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(
                        '${_estudianteRegistrado!.nombres} ${_estudianteRegistrado!.apellidoPaterno} ${_estudianteRegistrado!.apellidoMaterno ?? ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('CI: ${_estudianteRegistrado!.ci}'),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text('Seleccione el Curso y Paralelo:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                if (_isLoadingCursos)
                  const Center(child: CircularProgressIndicator())
                else if (_cursosDisponibles.isEmpty)
                  const Text('No hay cursos disponibles.')
                else
                  DropdownButtonFormField<Curso>(
                    value: _cursoSeleccionado,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    hint: const Text('Seleccionar...'),
                    isExpanded: true,
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
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
          ),

          // STEP 3: CONFIRMACIÓN
          Step(
            title: const Text('Finalizado'),
            content: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                   const SizedBox(height: 16),
                   const Text(
                     '¡Inscripción Exitosa!',
                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   Text('El estudiante ha sido inscrito correctamente en:\n${_cursoSeleccionado?.gradoNombre ?? ""} "${_cursoSeleccionado?.paralelo ?? ""}"'),
                   const SizedBox(height: 24),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       OutlinedButton.icon(
                         onPressed: () {
                           // Reset wizard
                           setState(() {
                             _currentStep = 0;
                             _estudianteRegistrado = null;
                             _cursoSeleccionado = null;
                           });
                         }, 
                         icon: const Icon(Icons.person_add),
                         label: const Text('Nueva Inscripción'),
                       ),
                       const SizedBox(width: 16),
                       FilledButton.icon(
                         onPressed: () => context.go('/dashboard-secretaria/matriculados'), 
                         icon: const Icon(Icons.list),
                         label: const Text('Ir a Matriculados'),
                       ),
                     ],
                   )
                ],
              ),
            ),
            isActive: _currentStep >= 2,
            state: StepState.complete,
          ),
        ],
      ),
    );
  }
}
