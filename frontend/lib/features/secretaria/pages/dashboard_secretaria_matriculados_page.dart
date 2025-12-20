import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/gestion_service.dart';
import '../services/inscripcion_service.dart';

class ListaMatriculadosPage extends StatefulWidget {
  const ListaMatriculadosPage({super.key});

  @override
  State<ListaMatriculadosPage> createState() => _ListaMatriculadosPageState();
}

class _ListaMatriculadosPageState extends State<ListaMatriculadosPage> {
  final GestionService _gestionService = GestionService();
  final InscripcionService _inscripcionService = InscripcionService();
  
  bool _isLoading = true;
  String? _error;
  Gestion? _gestionActiva;
  List<dynamic> _inscripciones = [];
  List<dynamic> _inscripcionesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() { 
      _isLoading = true; 
      _error = null;
    });
    
    try {
      // 1. Get active gestion
      final gestiones = await _gestionService.getAll();
      final activa = gestiones.firstWhere((g) => g.activa, orElse: () => gestiones.last);
      
      // 2. Get enrollments
      final inscripciones = await _inscripcionService.listarPorGestion(activa.idGestion);
      
      setState(() {
        _gestionActiva = activa;
        _inscripciones = inscripciones;
        _inscripcionesFiltradas = inscripciones;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrar(String query) {
    if (query.isEmpty) {
      setState(() => _inscripcionesFiltradas = _inscripciones);
      return;
    }
    
    setState(() {
      _inscripcionesFiltradas = _inscripciones.where((ins) {
        final est = ins['estudiante'] ?? {};
        final nombre = '${est['nombres']} ${est['apellidoPaterno']} ${est['apellidoMaterno'] ?? ''}'.toLowerCase();
        final ci = (est['ci'] ?? '').toString().toLowerCase();
        final curso = (ins['cursoNombre'] ?? '').toString().toLowerCase();
        
        return nombre.contains(query.toLowerCase()) || 
               ci.contains(query.toLowerCase()) ||
               curso.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Lista de Matriculados ${_gestionActiva != null ? _gestionActiva!.anio : ""}',
      child: Column(
        children: [
          // Header / Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por Nombre, CI o Curso',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filtrar,
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _error != null 
                ? Center(child: Text('Error: $_error'))
                : _inscripcionesFiltradas.isEmpty
                  ? const Center(child: Text('No hay inscripciones registradas.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _inscripcionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final inscripcion = _inscripcionesFiltradas[index];
                        final est = inscripcion['estudiante'] ?? {};
                        final curso = inscripcion['curso'] ?? {};
                        final fecha = DateTime.tryParse(inscripcion['fechaInscripcion'] ?? '');
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(est['nombres']?[0] ?? 'E', style: const TextStyle(color: Colors.blue)),
                            ),
                            title: Text('${est['nombres']} ${est['apellidoPaterno']} ${est['apellidoMaterno'] ?? ''}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.class_, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text('${curso['nombreGrado']} "${curso['paralelo']}" - ${curso['turno']}'),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'Sin fecha'),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(inscripcion['estado'] ?? 'ACTIVO', style: const TextStyle(fontSize: 10, color: Colors.white)),
                              backgroundColor: (inscripcion['estado'] == 'RETIRADO') ? Colors.red : Colors.green,
                              padding: EdgeInsets.zero,
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
