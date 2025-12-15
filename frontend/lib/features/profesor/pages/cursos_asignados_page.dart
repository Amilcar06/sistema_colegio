import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import 'package:go_router/go_router.dart';

class CursosAsignadosPage extends StatefulWidget {
  const CursosAsignadosPage({super.key});

  @override
  State<CursosAsignadosPage> createState() => _CursosAsignadosPageState();
}

class _CursosAsignadosPageState extends State<CursosAsignadosPage> {
  final ProfesorService _service = ProfesorService();
  bool _isLoading = true;
  List<dynamic> _asignaciones = [];

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
                // Estructura esperada: { "id": 1, "materia": {...}, "curso": {...}, "gestion": {...} }
                final materia = item['materia']?['nombre'] ?? 'Sin materia';
                final curso = item['curso']?['nombre'] ?? '';
                final paralelo = item['curso']?['paralelo'] ?? '';
                final gestion = item['gestion']?['anio']?.toString() ?? '';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materia,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 8),
                        Text('Curso: $curso "$paralelo"', style: const TextStyle(fontSize: 16)),
                        Text('Gestión: $gestion', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.grade),
                            label: const Text('Registrar Notas'),
                            onPressed: () {
                              // Navegar a registro de notas
                              // Necesitamos pasar el ID de la asignacion
                              context.push('/dashboard-profesor/notas/${item['idAsignacion']}');
                            },
                          ),
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
