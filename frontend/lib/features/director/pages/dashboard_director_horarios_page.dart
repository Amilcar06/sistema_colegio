import 'package:flutter/material.dart';
import '../../../../core/api_config.dart'; 
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
  
  final ScrollController _horizontalController = ScrollController();

  List<dynamic> _cursos = [];
  List<dynamic> _asignaciones = [];
  List<dynamic> _horarios = [];

  int? _selectedCursoId;
  bool _isLoading = false;

  final List<String> _dias = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'];
  final double _hourHeight = 60.0;
  final double _dayColumnWidth = 140.0;
  final int _startHour = 7; // 7:00 AM
  final int _endHour = 19;  // 7:00 PM

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }
  
  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
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
      
      // Auto-scroll to current day after loading
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentDay());
      
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _scrollToCurrentDay() {
    final now = DateTime.now();
    int dayIndex = now.weekday - 1; // Mon=0
    if (dayIndex > 5) dayIndex = 0; // Sun -> Mon

    // Calculate offset: Width of time column (50) + dayIndex * columnWidth
    // But since days are inside a Row in SingleChildScrollView, and TimeColumn is sticky or separate.. 
    // In our implementation below, they are in a Row.
    // Time Column (50) + (dayIndex * 140)
    
    // However, if we scroll only the days, we need to separate TimeColumn.
    // Let's scroll the whole Row.
    double offset = dayIndex * _dayColumnWidth;
    
    // Clamp offset
    if (_horizontalController.hasClients) {
       // Center it if possible or just scroll to start
      _horizontalController.animateTo(
        offset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _abrirDialogo({Map<String, dynamic>? horarioExistente}) async {
    if (_selectedCursoId == null) return;

    // Controllers
    int? selectedAsignacionId = horarioExistente?['idAsignacion'];
    String selectedDia = horarioExistente?['diaSemana'] ?? 'LUNES';
    TimeOfDay inicio = horarioExistente != null 
        ? _parseTime(horarioExistente['horaInicio']) 
        : const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay fin = horarioExistente != null 
        ? _parseTime(horarioExistente['horaFin']) 
        : const TimeOfDay(hour: 9, minute: 30);
    String aula = horarioExistente?['aula'] ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text(horarioExistente == null ? 'Agregar Clase' : 'Editar Clase'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Materia'),
                    value: selectedAsignacionId,
                    items: _asignaciones.map((a) {
                      return DropdownMenuItem<int>(
                        value: a.idAsignacion,
                        child: Text(
                            "${a.nombreMateria} - ${a.nombreProfesor}", 
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => selectedAsignacionId = val,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Día'),
                    value: selectedDia,
                    items: _dias.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setModalState(() => selectedDia = val!),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text("Inicio", style: TextStyle(fontSize: 12)),
                          subtitle: Text(inicio.format(context)),
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: inicio);
                            if (t != null) setModalState(() => inicio = t);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text("Fin", style: TextStyle(fontSize: 12)),
                          subtitle: Text(fin.format(context)),
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: fin);
                            if (t != null) setModalState(() => fin = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Aula'),
                    controller: TextEditingController(text: aula),
                    onChanged: (val) => aula = val,
                  )
                ],
              ),
            ),
            actions: [
              if (horarioExistente != null)
                 TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                     Navigator.pop(context);
                     _confirmarEliminar(horarioExistente['idHorario']);
                  },
                  child: const Text('Eliminar'),
                ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (selectedAsignacionId == null) return;
                  try {
                    final sInicio = '${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}:00';
                    final sFin = '${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}:00';

                    final data = {
                      'idAsignacion': selectedAsignacionId,
                      'diaSemana': selectedDia,
                      'horaInicio': sInicio,
                      'horaFin': sFin,
                      'aula': aula
                    };

                    if (horarioExistente == null) {
                      await _horarioService.crearHorario(data);
                    } else {
                      await _horarioService.updateHorario(horarioExistente['idHorario'], data);
                    }
                    
                    Navigator.pop(context);
                    _cargarDatosCurso(_selectedCursoId!);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _confirmarEliminar(int id) {
     showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Clase'),
        content: const Text('¿Seguro que deseas eliminar este horario?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close confirm
              try {
                await _horarioService.eliminarHorario(id);
                _cargarDatosCurso(_selectedCursoId!);
              } catch(e){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Eliminar'),
          )
        ],
      )
     );
  }

  TimeOfDay _parseTime(String timeStr) {
    // Format HH:mm:ss
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      // title: 'Gestión de Horarios', 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Curso',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
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
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _selectedCursoId != null ? () => _abrirDialogo() : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Clase'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Grid content
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _selectedCursoId == null 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.calendar_view_week, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Seleccione un curso para ver y editar el horario", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : _buildWeeklyGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Column (Fixed LEft)
        SizedBox(
          width: 50,
          child: _buildTimeColumn(),
        ),
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _dayColumnWidth * _dias.length,
              child: Row(
                children: _dias.map((dia) => SizedBox(width: _dayColumnWidth, child: _buildDayColumn(dia))).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumn() {
    return Column(
      children: [
        Container(height: 40, alignment: Alignment.center, child: const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
        ...List.generate(_endHour - _startHour + 1, (index) {
          final hour = _startHour + index;
          return Container(
            height: _hourHeight,
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
               border: Border(top: BorderSide(color: Colors.grey, width: 0.5))
            ),
            child: Text('$hour:00', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          );
        })
      ],
    );
  }

  Widget _buildDayColumn(String dia) {
    // Filter schedules for this day
    final clasesDia = _horarios.where((h) => h['diaSemana'] == dia).toList();
    
    // Check if it's today
    final now = DateTime.now();
    final weekDays = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];
    final todayStr = (now.weekday <= 6) ? weekDays[now.weekday - 1] : '';
    final isToday = dia == todayStr;

    return Container(
      decoration: BoxDecoration(
        color: isToday ? Colors.blue.withOpacity(0.05) : null,
        border: const Border(left: BorderSide(color: Colors.grey, width: 0.5))
      ),
      child: Column(
        children: [
          // Header Day
          Container(
            height: 40, 
            alignment: Alignment.center, 
            color: isToday ? Colors.blue : Colors.grey[200],
            child: Text(
              dia.substring(0, 3), 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.black87
              )
            )
          ),
          // Grid area
          SizedBox(
            height: (_endHour - _startHour + 1) * _hourHeight,
            child: Stack(
              children: [
                // Background grid lines
                ...List.generate(_endHour - _startHour + 1, (index) {
                   return Positioned(
                     top: index * _hourHeight,
                     left: 0, right: 0,
                     child: Container(
                       height: _hourHeight, 
                       decoration: const BoxDecoration(
                         border: Border(top: BorderSide(color: Colors.grey, width: 0.2))
                       )
                     ),
                   );
                }),
                
                // Current Time Indicator (Only if today)
                if (isToday) _buildCurrentTimeIndicator(),

                // Schedule Blocks
                ...clasesDia.map((clase) {
                  final inicio = _parseTime(clase['horaInicio']);
                  final fin = _parseTime(clase['horaFin']);
                  
                  final startOffset = (inicio.hour - _startHour) * _hourHeight + (inicio.minute / 60) * _hourHeight;
                  final durationHours = (fin.hour - inicio.hour) + (fin.minute - inicio.minute) / 60;
                  final height = durationHours * _hourHeight;

                  return Positioned(
                    top: startOffset,
                    left: 2, right: 2,
                    height: height,
                    child: GestureDetector(
                      onTap: () => _abrirDialogo(horarioExistente: clase),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getColorForMateria(clase['nombreMateria'] ?? ''),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(1,1))
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clase['nombreMateria'] ?? 'Invalido', 
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis
                            ),
                            Text(
                              '${inicio.format(context)} - ${fin.format(context)}',
                               style: const TextStyle(color: Colors.white70, fontSize: 9),
                               overflow: TextOverflow.ellipsis
                            ),
                            if (clase['aula'] != null)
                             Text(
                               'Aula: ${clase['aula']}',
                                style: const TextStyle(color: Colors.white70, fontSize: 9),
                                overflow: TextOverflow.ellipsis
                             ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    
    // Check if within bounds
    if (now.hour < _startHour || now.hour > _endHour) return const SizedBox();
    
    final offset = (now.hour - _startHour) * _hourHeight + (now.minute / 60) * _hourHeight;
    
    return Positioned(
      top: offset,
      left: 0, 
      right: 0,
      child: Row(
        children: [
           const CircleAvatar(radius: 3, backgroundColor: Colors.red),
           Expanded(child: Container(height: 2, color: Colors.red)),
        ],
      ),
    );
  }

  Color _getColorForMateria(String materia) {
     final hash = materia.hashCode;
     final colors = [
       Colors.blue, Colors.red, Colors.green, Colors.orange, 
       Colors.purple, Colors.teal, Colors.indigo, Colors.brown
     ];
     return colors[hash.abs() % colors.length];
  }
}
