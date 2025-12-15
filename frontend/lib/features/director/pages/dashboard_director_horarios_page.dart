import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/curso_service.dart';
import '../../director/services/asignacion_service.dart';
import '../services/horario_service.dart';

class DashboardDirectorHorariosPage extends StatefulWidget {
  const DashboardDirectorHorariosPage({super.key});

  @override
  State<DashboardDirectorHorariosPage> createState() =>
      _DashboardDirectorHorariosPageState();
}

class _DashboardDirectorHorariosPageState
    extends State<DashboardDirectorHorariosPage> {
  final CursoService _cursoService = CursoService();
  final AsignacionService _asignacionService = AsignacionService();
  final HorarioService _horarioService = HorarioService();

  List<dynamic> _cursos = [];
  List<dynamic> _asignaciones = [];
  List<dynamic> _horarios = [];

  int? _selectedCursoId;
  bool _isLoading = false;

  final List<String> _dias = [
    'LUNES',
    'MARTES',
    'MIERCOLES',
    'JUEVES',
    'VIERNES',
    'SABADO'
  ];

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    setState(() => _isLoading = true);
    try {
      final cursos = await _cursoService.listarCursos(2025); // TODO: Gestion dinámica
      setState(() {
        _cursos = cursos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarDatosCurso(int idCurso) async {
    setState(() => _isLoading = true);
    try {
      final asignaciones = await _asignacionService.listarPorCurso(idCurso);
      final horarios = await _horarioService.listarPorCurso(idCurso);
      setState(() {
        _asignaciones = asignaciones;
        _horarios = horarios;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _agregarHorario() async {
    if (_selectedCursoId == null) return;

    // Controllers para el Dialog
    int? selectedAsignacionId;
    String selectedDia = 'LUNES';
    TimeOfDay inicio = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay fin = const TimeOfDay(hour: 9, minute: 30);
    String aula = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Agregar Horario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Materia'),
                    items: _asignaciones.map((a) {
                      return DropdownMenuItem<int>(
                        value: a['idAsignacion'] as int,
                        child: Text(
                            "${a['nombreMateria']} - ${a['nombreProfesor']}"),
                      );
                    }).toList(),
                    onChanged: (val) => selectedAsignacionId = val,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Día'),
                    value: selectedDia,
                    items: _dias
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => selectedDia = val!,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text("Inicio: ${inicio.format(context)}"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: inicio);
                      if (t != null) setModalState(() => inicio = t);
                    },
                  ),
                  ListTile(
                    title: Text("Fin: ${fin.format(context)}"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: fin);
                      if (t != null) setModalState(() => fin = t);
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Aula'),
                    onChanged: (val) => aula = val,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (selectedAsignacionId == null) return;
                  try {
                    // Formato HH:mm:ss
                    final sInicio =
                        '${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}:00';
                    final sFin =
                        '${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}:00';

                    await _horarioService.crearHorario({
                      'idAsignacion': selectedAsignacionId,
                      'diaSemana': selectedDia,
                      'horaInicio': sInicio,
                      'horaFin': sFin,
                      'aula': aula
                    });
                    Navigator.pop(context);
                    _cargarDatosCurso(_selectedCursoId!);
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  void _eliminarHorario(int id) async {
      try {
          await _horarioService.eliminarHorario(id);
          _cargarDatosCurso(_selectedCursoId!);
      } catch(e){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Gestión de Horarios',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                if (val != null) _cargarDatosCurso(val);
              },
            ),
            const SizedBox(height: 20),

            if (_selectedCursoId != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Horario Semanal',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _agregarHorario,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Clase'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _horarios.isEmpty
                        ? const Center(
                            child:
                                Text('No hay horarios definidos para este curso.'))
                        : ListView.builder(
                            itemCount: _horarios.length,
                            itemBuilder: (context, index) {
                              final h = _horarios[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(h['diaSemana']
                                        .toString()
                                        .substring(0, 2)),
                                  ),
                                  title: Text(h['nombreMateria'] ?? 'Materia'),
                                  subtitle: Text(
                                      "${h['horaInicio']} - ${h['horaFin']} | Aula: ${h['aula'] ?? 'S/A'} | Prof: ${h['nombreProfesor']}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _eliminarHorario(h['idHorario']),
                                  ),
                                ),
                              );
                            },
                          ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
