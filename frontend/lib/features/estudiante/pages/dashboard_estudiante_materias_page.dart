import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/estudiante_service.dart';
import '../services/nota_service.dart';
import '../models/estudiante_response.dart';

class DashboardEstudianteMateriasPage extends StatefulWidget {
  const DashboardEstudianteMateriasPage({super.key});

  @override
  State<DashboardEstudianteMateriasPage> createState() => _DashboardEstudianteMateriasPageState();
}

class _DashboardEstudianteMateriasPageState extends State<DashboardEstudianteMateriasPage> {
  final _estudianteService = EstudianteService();
  final _notaService = NotaService();
  
  bool _isLoading = true;
  EstudianteResponseDTO? _estudiante;
  List<Map<String, dynamic>> _materias = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  Future<void> _cargarMaterias() async {
    setState(() => _isLoading = true);
    try {
      final perfil = await _estudianteService.obtenerPerfil();
      _estudiante = perfil;

      final gestiones = await _estudianteService.listarGestiones(perfil.idEstudiante);
      int? currentGestionId;
      if (gestiones.isNotEmpty) {
          final activa = gestiones.firstWhere((g) => g['estado'] == true, orElse: () => gestiones.last);
          currentGestionId = activa['idGestion'];
      }

      if (currentGestionId != null) {
        final boletin = await _notaService.obtenerBoletin(perfil.idEstudiante, idGestion: currentGestionId);
        final List<dynamic> notasRaw = boletin['notas'] ?? [];
        
        // Extract unique subjects
        final Map<String, Map<String, dynamic>> subjectsMap = {};
        for (var n in notasRaw) {
          final materia = n['materia'] ?? 'Desconocida';
          if (!subjectsMap.containsKey(materia)) {
            subjectsMap[materia] = {
              'materia': materia,
              'profesor': n['nombreProfesor'] ?? 'No Asignado',
              // Add mock schedule or more info if available
              'horario': 'Por definir', 
            };
          }
        }
        _materias = subjectsMap.values.toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mis Materias',
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null 
          ? Center(child: Text('Error: $_error'))
          : _materias.isEmpty
            ? const Center(child: Text('No tienes materias registradas.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _materias.length,
                itemBuilder: (context, index) {
                  final mat = _materias[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(mat['materia'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      title: Text(mat['materia'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(mat['profesor']),
                            ],
                          ),
                        ],
                      ),
                      // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
    );
  }
}
