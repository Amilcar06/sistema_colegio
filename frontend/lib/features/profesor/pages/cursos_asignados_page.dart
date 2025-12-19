import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/pdf_util.dart';
import '../models/asignacion_docente_response.dart';


class CursosAsignadosPage extends StatefulWidget {
  const CursosAsignadosPage({super.key});

  @override
  State<CursosAsignadosPage> createState() => _CursosAsignadosPageState();
}

class _CursosAsignadosPageState extends State<CursosAsignadosPage> {
  final ProfesorService _service = ProfesorService();
  bool _isLoading = true;
  List<AsignacionDocenteResponse> _asignaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    try {
      final datos = await _service.getMisCursos();
      setState(() {
        _asignaciones = datos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mis Cursos Asignados',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _asignaciones.length,
              itemBuilder: (context, index) {
                final item = _asignaciones[index];
                
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombreMateria,
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Theme.of(context).primaryColor
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Curso: ${item.nombreCurso}', style: const TextStyle(fontSize: 16)),
                        Text('Gestión: ${item.anioGestion}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                             Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.grade),
                                label: const Text('Notas'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  context.push('/dashboard-profesor/notas/${item.idAsignacion}');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.list_alt),
                                label: const Text('Estudiantes'),
                                onPressed: () {
                                  // Navegar a lista de estudiantes
                                  context.push('/dashboard-profesor/estudiantes/${item.idCurso}');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
