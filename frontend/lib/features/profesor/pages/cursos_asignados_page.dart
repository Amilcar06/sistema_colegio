import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/pdf_util.dart';


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
                // Estructura REAL: { "idAsignacion": 1, "nombreMateria": "...", "idCurso": 1, "nombreCurso": "...", "anioGestion": 2025 }
                final materia = item['nombreMateria'] ?? 'Sin materia';
                final curso = item['nombreCurso'] ?? 'Curso';
                final gestion = item['anioGestion']?.toString() ?? '';

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
                        Text('Curso: $curso', style: const TextStyle(fontSize: 16)),
                        Text('Gestión: $gestion', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.grade),
                            label: const Text('Registrar Notas'),
                            onPressed: () {
                              context.push('/dashboard-profesor/notas/${item['idAsignacion']}');
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Descargar Lista de Curso'),
                            onPressed: () async {
                              try {
                                final pdfData = await _service.descargarListaCurso(item['idCurso']); 
                                PdfUtil.descargarPdfWeb(pdfData, 'Lista_${curso}.pdf');
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al descargar lista: $e')),
                                );
                              }
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
