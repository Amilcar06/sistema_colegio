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
  final HorarioService _horarioService = HorarioService();

  List<dynamic> _horarios = [];
  bool _isLoading = true;
  String _cursoNombre = "";

  // Días de la semana para las pestañas
  final List<String> _dias = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'];

  @override
  void initState() {
    super.initState();
    _cargarHorario();
  }

  Future<void> _cargarHorario() async {
    try {
      final perfil = await _estudianteService.obtenerPerfil();
      final inscripciones = await _inscripcionService.listarPorEstudiante(perfil.idEstudiante);
      
      if (inscripciones.isNotEmpty) {
         final inscripcionActual = inscripciones.last;
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
      }
    }
  }

  List<dynamic> _filtrarPorDia(String dia) {
    return _horarios.where((h) {
      // Normalizamos string para comparar (backend puede enviar 'LUNES' o 'Lunes')
      String hDia = h['diaSemana'].toString().toUpperCase();
      // Manejo de tildes básico por si acaso
      hDia = hDia.replaceAll('É', 'E').replaceAll('Á', 'A');
      String target = dia.replaceAll('É', 'E');
      return hDia == target;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _dias.length,
      child: MainScaffold(
        title: 'Mi Horario - $_cursoNombre',
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    color: Colors.indigo.shade50,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Colors.indigo,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.indigo,
                      tabs: _dias.map((dia) => Tab(text: dia.substring(0, 3))).toList(),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: _dias.map((dia) {
                        final listaDia = _filtrarPorDia(dia);
                        if (listaDia.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.weekend, size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('Sin clases el $dia', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        }
                        
                        // Ordenar por hora
                        listaDia.sort((a, b) => a['horaInicio'].toString().compareTo(b['horaInicio'].toString()));

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: listaDia.length,
                          itemBuilder: (context, index) {
                            final h = listaDia[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.menu_book_rounded, color: Colors.indigo),
                                ),
                                title: Text(h['nombreMateria'] ?? 'Materia', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${h['horaInicio']} - ${h['horaFin']}'),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.room, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(h['aula'] ?? 'Sin aula'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
