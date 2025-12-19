import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import '../models/boletin_notas_model.dart';

class DashboardProfesorInscritosPage extends StatefulWidget {
  final String idAsignacion;

  const DashboardProfesorInscritosPage({super.key, this.idAsignacion = ''});

  @override
  State<DashboardProfesorInscritosPage> createState() => _DashboardProfesorInscritosPageState();
}

class _DashboardProfesorInscritosPageState extends State<DashboardProfesorInscritosPage> {
  bool _isLoading = true;
  List<BoletinNotasModel> _estudiantes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarEstudiantes();
    });
  }

  Future<void> _cargarEstudiantes() async {
    if (widget.idAsignacion.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No se seleccionó ningún curso.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profesorService = ProfesorService();
      
      // We reuse getBoletinCurso with 'PRIMER' trimester default to get list
      final estudiantes = await profesorService.getBoletinCurso(
        int.parse(widget.idAsignacion),
        'PRIMER', 
      );

      setState(() {
        _estudiantes = estudiantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar estudiantes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Listado de Estudiantes',
      child: _content(),
    );
  }

  Widget _content() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarEstudiantes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_estudiantes.isEmpty) {
      return const Center(child: Text('No hay estudiantes inscritos en este curso (o error en carga).'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Estudiantes Inscritos (${_estudiantes.length})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _estudiantes.length,
            itemBuilder: (context, index) {
              final est = _estudiantes[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      est.nombreEstudiante.isNotEmpty ? est.nombreEstudiante[0].toUpperCase() : '?',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  title: Text(
                    est.nombreEstudiante,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID Estudiante: ${est.idEstudiante}'),
                  onTap: () {
                    // Future: Navigate to detailed student profile
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
