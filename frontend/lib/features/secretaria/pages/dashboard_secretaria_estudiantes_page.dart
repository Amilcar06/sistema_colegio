import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../estudiante/models/estudiante_response.dart';
import '../../estudiante/services/estudiante_service.dart';

class DashboardSecretariaEstudiantesPage extends StatefulWidget {
  const DashboardSecretariaEstudiantesPage({super.key});

  @override
  State<DashboardSecretariaEstudiantesPage> createState() => _DashboardSecretariaEstudiantesPageState();
}

class _DashboardSecretariaEstudiantesPageState extends State<DashboardSecretariaEstudiantesPage> {
  final EstudianteService _service = EstudianteService();
  List<EstudianteResponseDTO> _estudiantes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    try {
      final lista = await _service.listar();
      setState(() {
        _estudiantes = lista;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Gestión de Estudiantes',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _estudiantes.length,
              itemBuilder: (context, index) {
                final est = _estudiantes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(est.nombres[0])),
                    title: Text(est.nombreCompleto),
                    subtitle: Text('CI: ${est.ci}'),
                    trailing: Chip(
                      label: Text(est.estado ? 'Activo' : 'Inactivo'),
                      backgroundColor: est.estado ? Colors.green[100] : Colors.red[100],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
