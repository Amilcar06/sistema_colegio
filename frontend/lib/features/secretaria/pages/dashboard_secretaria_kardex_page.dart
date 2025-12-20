import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../estudiante/controller/estudiante_controller.dart';
import '../../estudiante/models/estudiante_response.dart';
import '../services/inscripcion_service.dart';

class KardexEstudiantePage extends StatefulWidget {
  const KardexEstudiantePage({super.key});

  @override
  State<KardexEstudiantePage> createState() => _KardexEstudiantePageState();
}

class _KardexEstudiantePageState extends State<KardexEstudiantePage> {
  final TextEditingController _searchController = TextEditingController();
  final InscripcionService _inscripcionService = InscripcionService();
  
  List<EstudianteResponseDTO> _estudiantesSugestiones = [];
  EstudianteResponseDTO? _estudianteSeleccionado;
  List<dynamic> _historialInscripciones = [];
  bool _isLoadingHistorial = false;

  @override
  void initState() {
    super.initState();
    // Pre-load students for search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstudianteController>().cargarEstudiantes();
    });
  }

  void _filtrarEstudiantes(String query) {
    if (query.isEmpty) {
      setState(() => _estudiantesSugestiones = []);
      return;
    }
    final todos = context.read<EstudianteController>().estudiantes;
    setState(() {
      _estudiantesSugestiones = todos.where((e) {
        final nombre = '${e.nombres} ${e.apellidoPaterno}'.toLowerCase();
        final ci = e.ci.toLowerCase();
        return nombre.contains(query.toLowerCase()) || ci.contains(query.toLowerCase());
      }).take(5).toList();
    });
  }

  Future<void> _seleccionarEstudiante(EstudianteResponseDTO est) async {
    setState(() {
      _estudianteSeleccionado = est;
      _searchController.text = '${est.nombres} ${est.apellidoPaterno}';
      _estudiantesSugestiones = [];
      _isLoadingHistorial = true;
    });

    try {
      final historial = await _inscripcionService.listarPorEstudiante(est.idEstudiante);
      setState(() {
        _historialInscripciones = historial;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar historial: $e')));
    } finally {
      setState(() => _isLoadingHistorial = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EstudianteController>();

    return MainScaffold(
      title: 'Kardex Estudiante',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // BUSCADOR
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Estudiante (Nombre o CI)',
                prefixIcon: const Icon(Icons.person_search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear), 
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _estudianteSeleccionado = null;
                      _historialInscripciones = [];
                      _estudiantesSugestiones = [];
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filtrarEstudiantes,
            ),
            
            // RESULTADOS DE BÚSQUEDA (OVERLAY)
            if (_estudiantesSugestiones.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _estudiantesSugestiones.length,
                  itemBuilder: (_, index) {
                    final est = _estudiantesSugestiones[index];
                    return ListTile(
                      title: Text('${est.nombres} ${est.apellidoPaterno}'),
                      subtitle: Text('CI: ${est.ci}'),
                      onTap: () => _seleccionarEstudiante(est),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 20),

            // KARDEX CONTENT
            if (_estudianteSeleccionado == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_shared_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Seleccione un estudiante para ver su Kardex', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    // PERFIL HEADER
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(_estudianteSeleccionado!.nombres[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_estudianteSeleccionado!.nombres} ${_estudianteSeleccionado!.apellidoPaterno} ${_estudianteSeleccionado!.apellidoMaterno ?? ''}', 
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('CI: ${_estudianteSeleccionado!.ci}', style: const TextStyle(color: Colors.grey)),
                                  Text('Email: ${_estudianteSeleccionado!.correo}', style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Chip(
                                    label: Text(_estudianteSeleccionado!.estado ? 'ACTIVO' : 'INACTIVO'),
                                    backgroundColor: _estudianteSeleccionado!.estado ? Colors.green.shade100 : Colors.red.shade100,
                                    labelStyle: TextStyle(color: _estudianteSeleccionado!.estado ? Colors.green.shade800 : Colors.red.shade800),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // DATOS FAMILIARES
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.family_restroom),
                            title: const Text('Información Familiar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: Text(_estudianteSeleccionado!.nombrePadre ?? 'No registrado'),
                            subtitle: const Text('Padre'),
                            trailing: Text(_estudianteSeleccionado!.telefonoPadre ?? ''),
                          ),
                          ListTile(
                            title: Text(_estudianteSeleccionado!.nombreMadre ?? 'No registrado'),
                            subtitle: const Text('Madre'),
                            trailing: Text(_estudianteSeleccionado!.telefonoMadre ?? ''),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // HISTORIAL ACADÉMICO
                    const Text('Historial de Inscripciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_isLoadingHistorial)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (_historialInscripciones.isEmpty)
                      const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Sin inscripciones registradas.')))
                    else
                      ..._historialInscripciones.map((ins) {
                        final curso = ins['curso'] ?? {};
                        final gestion = ins['gestion'] ?? {}; // If backend returns it deeper, adjust
                        // Assuming backend structure for now, adjust based on real response
                        final fecha = DateTime.tryParse(ins['fechaInscripcion'] ?? '');
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.history_edu, color: Colors.blueAccent),
                            title: Text('${curso['nombreGrado']} "${curso['paralelo']}"'),
                            subtitle: Text('Gestión ${gestion['anio'] ?? "Actual"} - ${curso['turno']}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(ins['estado'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (fecha != null) Text(DateFormat('dd/MM/yyyy').format(fecha), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
