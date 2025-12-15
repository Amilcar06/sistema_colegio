import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../../estudiante/services/estudiante_service.dart';
import '../../director/services/horario_service.dart';
import '../../secretaria/services/inscripcion_service.dart';

class DashboardEstudianteHorariosPage extends StatefulWidget {
  const DashboardEstudianteHorariosPage({super.key});

  @override
  State<DashboardEstudianteHorariosPage> createState() =>
      _DashboardEstudianteHorariosPageState();
}

class _DashboardEstudianteHorariosPageState
    extends State<DashboardEstudianteHorariosPage> {
  final EstudianteService _estudianteService = EstudianteService();
  final InscripcionService _inscripcionService = InscripcionService();
  final HorarioService _horarioService = HorarioService(); // Reutilizamos el servicio

  List<dynamic> _horarios = [];
  bool _isLoading = true;
  String _cursoNombre = "";

  @override
  void initState() {
    super.initState();
    _cargarHorario();
  }

  Future<void> _cargarHorario() async {
    try {
      final perfil = await _estudianteService.obtenerPerfil();
      // Obtenemos inscripciones para saber el curso
      // TODO: Simplificar si el backend diera curso actual directamente
      final inscripciones = await _inscripcionService.listarPorEstudiante(perfil.idEstudiante);
      
      if (inscripciones.isNotEmpty) {
         // Tomamos la última inscripción activa (simplificación)
         final inscripcionActual = inscripciones.last; // Asumiendo orden
         // El endpoint de inscripciones devuelve detalles del curso? 
         // Si devuelve idCurso, llamamos a horarios
         if (inscripcionActual['idCurso'] != null) {
            final lista = await _horarioService.listarPorCurso(inscripcionActual['idCurso']);
            setState(() {
              _horarios = lista;
              _cursoNombre = inscripcionActual['nombreCurso'] ?? 'Mi Curso';
              _isLoading = false;
            });
            return;
         }
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silent fail or simple message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mi Horario',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _horarios.isEmpty
              ? const Center(child: Text('No tienes horarios asignados aún.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text("Curso: $_cursoNombre", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 10),
                       Expanded(
                         child: ListView.builder(
                            itemCount: _horarios.length,
                            itemBuilder: (context, index) {
                              final h = _horarios[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    child: Text(h['diaSemana'].toString().substring(0, 1)),
                                  ),
                                  title: Text("${h['diaSemana']} - ${h['nombreMateria']}"),
                                  subtitle: Text("${h['horaInicio']} - ${h['horaFin']} | Aula: ${h['aula']}"),
                                  trailing: const Icon(Icons.access_time),
                                ),
                              );
                            },
                         ),
                       ),
                    ],
                  ),
                ),
    );
  }
}
