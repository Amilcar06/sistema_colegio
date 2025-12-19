import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../../profesor/services/profesor_service.dart';

class DashboardProfesorHorariosPage extends StatefulWidget {
  const DashboardProfesorHorariosPage({super.key});

  @override
  State<DashboardProfesorHorariosPage> createState() => _DashboardProfesorHorariosPageState();
}

class _DashboardProfesorHorariosPageState extends State<DashboardProfesorHorariosPage> {
  final ProfesorService _profesorService = ProfesorService();
  final ScrollController _scrollController = ScrollController();

  Map<String, List<dynamic>> _horariosPorDia = {
    'LUNES': [],
    'MARTES': [],
    'MIERCOLES': [],
    'JUEVES': [],
    'VIERNES': [],
    'SABADO': [],
  };
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHorario();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarHorario() async {
    try {
      final lista = await _profesorService.getMisHorarios();
      final Map<String, List<dynamic>> grouped = {
        'LUNES': [], 'MARTES': [], 'MIERCOLES': [], 'JUEVES': [], 'VIERNES': [], 'SABADO': [],
      };

      for (var h in lista) {
        final dia = h['diaSemana'] as String;
        if (grouped.containsKey(dia)) {
          grouped[dia]!.add(h);
        } else {
          grouped.putIfAbsent(dia, () => []).add(h);
        }
      }

      grouped.forEach((key, value) {
        value.sort((a, b) {
          final t1 = a['horaInicio'].toString();
          final t2 = b['horaInicio'].toString();
          return t1.compareTo(t2);
        });
      });

      if (mounted) {
        setState(() {
          _horariosPorDia = grouped;
          _isLoading = false;
        });
        
        // Auto-scroll to current day after build
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentDay());
      }
    } catch (e) {
      debugPrint('Error loading schedules: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToCurrentDay() {
    final now = DateTime.now();
    // Monday = 1, Saturday = 6. 
    // Indices in list: Mon=0, Tue=1..
    int dayIndex = now.weekday - 1; 
    
    // If Sunday(7), show Monday
    if (dayIndex > 5) dayIndex = 0; 
    if (dayIndex < 0) dayIndex = 0;

    // Card width 200 + margin 16 = 216
    final offset = dayIndex * 216.0;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mi Agenda Semanal',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _content(),
    );
  }

  Widget _content() {
    final daysToShow = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES'];
    if (_horariosPorDia['SABADO']!.isNotEmpty) daysToShow.add('SABADO');
    
    // Identify today for highlighting
    final now = DateTime.now();
    final weekDays = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];
    final todayStr = (now.weekday <= 6) ? weekDays[now.weekday - 1] : '';

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: daysToShow.map((dia) {
          final isToday = dia == todayStr;
          return _buildDayColumn(dia, _horariosPorDia[dia]!, isToday);
        }).toList(),
      ),
    );
  }

  Widget _buildDayColumn(String dia, List<dynamic> clases, bool isToday) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isToday ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? Colors.blue.shade200 : Colors.grey.shade200, 
          width: isToday ? 2 : 1
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getDayColor(dia),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Column(
              children: [
                Text(
                  dia,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: const Text('HOY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ),
          
          if (clases.isEmpty)
             const Padding(
               padding: EdgeInsets.all(24.0),
               child: Text('Sin clases', style: TextStyle(color: Colors.grey)),
             ),

          // Items
          ...clases.map((clase) => _buildClassCard(clase)),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> clase) {
    final materia = clase['nombreMateria'] ?? 'Materia';
    final curso = clase['nombreCurso'] ?? '';
    final inicio = clase['horaInicio']?.toString().substring(0, 5) ?? '00:00';
    final fin = clase['horaFin']?.toString().substring(0, 5) ?? '00:00';
    final aula = clase['aula'] ?? 'Sin aula';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
        border: Border(left: BorderSide(color: _getDayColor(clase['diaSemana']), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$inicio - $fin',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              // Icon(Icons.access_time, size: 12, color: Colors.indigo.shade200)
            ],
          ),
          const SizedBox(height: 4),
          Text(
            materia,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            curso,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.room, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                aula,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDayColor(String dia) {
    switch (dia) {
      case 'LUNES': return Colors.blue.shade700;
      case 'MARTES': return Colors.orange.shade700;
      case 'MIERCOLES': return Colors.green.shade700;
      case 'JUEVES': return Colors.red.shade700;
      case 'VIERNES': return Colors.purple.shade700;
      case 'SABADO': return Colors.teal.shade700;
      default: return Colors.grey;
    }
  }
}

