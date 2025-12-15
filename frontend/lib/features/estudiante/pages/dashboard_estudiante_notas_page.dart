import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/estudiante_service.dart';
import '../services/nota_service.dart';
import '../models/estudiante_response.dart';

class DashboardEstudianteNotasPage extends StatefulWidget {
  const DashboardEstudianteNotasPage({super.key});

  @override
  State<DashboardEstudianteNotasPage> createState() => _DashboardEstudianteNotasPageState();
}

class _DashboardEstudianteNotasPageState extends State<DashboardEstudianteNotasPage> {
  final _estudianteService = EstudianteService();
  final _notaService = NotaService();

  bool _isLoading = true;
  EstudianteResponseDTO? _estudiante;
  List<dynamic> _notas = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      // 1. Obtener perfil para saber el ID
      final est = await _estudianteService.obtenerPerfil();
      _estudiante = est;

      // 2. Obtener notas
      // Usamos el ID del estudiante recuperado
      final notas = await _notaService.obtenerNotas(est.idEstudiante);
      _notas = notas;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mis Calificaciones',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_estudiante == null) return const Center(child: Text('No se encontró información del estudiante.'));
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estudiante: ${_estudiante?.nombres} ${_estudiante?.apellidoPaterno}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Historial de Notas', style: TextStyle(fontSize: 16)),
          const Divider(),
          Expanded(
            child: _notas.isEmpty
                ? const Center(child: Text('No hay notas registradas.'))
                : ListView.builder(
                    itemCount: _notas.length,
                    itemBuilder: (context, index) {
                      final nota = _notas[index];
                      // Ajustar campos según el JSON real del backend
                      final materia = nota['nombreMateria'] ?? 'Materia desconocida';
                      final trimestre = nota['trimestre'] ?? '-';
                      final valor = nota['valor']?.toString() ?? '0';
                      
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.grade),
                          title: Text(materia.toString()),
                          subtitle: Text('Trimestre: $trimestre'),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(valor, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
