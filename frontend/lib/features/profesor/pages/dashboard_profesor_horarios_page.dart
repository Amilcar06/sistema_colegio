import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../../profesor/services/profesor_service.dart'; // Necesitamos obtener ID del profe
import '../../director/services/horario_service.dart';

class DashboardProfesorHorariosPage extends StatefulWidget {
  const DashboardProfesorHorariosPage({super.key});

  @override
  State<DashboardProfesorHorariosPage> createState() => _DashboardProfesorHorariosPageState();
}

class _DashboardProfesorHorariosPageState extends State<DashboardProfesorHorariosPage> {
  final ProfesorService _profesorService = ProfesorService();
  final HorarioService _horarioService = HorarioService();

  List<dynamic> _horarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHorario();
  }

  Future<void> _cargarHorario() async {
    try {
      final perfil = await _profesorService.obtenerPerfil();
      // El perfil debe tener idProfesor
      if (perfil.idProfesor != null) {
        final lista = await _horarioService.listarPorProfesor(perfil.idProfesor!);
        setState(() {
          _horarios = lista;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mi Agenda Semanal',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _horarios.isEmpty
              ? const Center(child: Text('No tienes clases programadas.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _horarios.length,
                  separatorBuilder: (c, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final h = _horarios[index];
                    return ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(h['diaSemana'].toString().substring(0, 3), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(h['horaInicio'].toString().substring(0, 5), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      title: Text("${h['nombreMateria']} (${h['nombreCurso']})"),
                      subtitle: Text("Aula: ${h['aula'] ?? 'Virtual'}"),
                    );
                  },
                ),
    );
  }
}
