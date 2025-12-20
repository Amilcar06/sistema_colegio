import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../controller/curso_controller.dart';
import '../models/grado.dart';
import '../models/curso.dart';
import '../services/configuracion_paralelo_service.dart';
import '../models/configuracion_paralelo.dart';

class DashboardDirectorCursosPage extends StatelessWidget {
  const DashboardDirectorCursosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CursoController(),
      child: const _CursosView(),
    );
  }
}

class _CursosView extends StatefulWidget {
  const _CursosView();

  @override
  State<_CursosView> createState() => _CursosViewState();
}

class _CursosViewState extends State<_CursosView> {
  TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CursoController>();
    final cursosFiltrados = controller.cursos.where((c) {
      final term = _filter.toLowerCase();
      return c.nombreGrado.toLowerCase().contains(term) ||
             c.paralelo.toLowerCase().contains(term) ||
             c.turno.toLowerCase().contains(term);
    }).toList();

    // Agrupar por nombre de grado + nivel
    final grouped = <String, List<Curso>>{};
    for (var c in cursosFiltrados) {
      final key = '${c.nombreGrado} - ${c.nivel}';
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(c);
    }
    
    // Ordenar llaves
    final sortedKeys = grouped.keys.toList()..sort();

    return MainScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Buscar curso...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _abrirDialogoCurso(context, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Curso'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
          ),
          if (controller.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (controller.errorMessage != null)
            Expanded(child: Center(child: Text('Error: ${controller.errorMessage}')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final groupKey = sortedKeys[index];
                  final cursosEnGrupo = grouped[groupKey]!;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            groupKey, 
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: Theme.of(context).primaryColor
                            )
                          ),
                        ),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: cursosEnGrupo.length,
                          itemBuilder: (context, i) => _buildCursoCard(context, controller, cursosEnGrupo[i]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCursoCard(BuildContext context, CursoController controller, Curso c) {
    // Generate a color based on the parallel letter for visual variety, or keep strict by shift
    final color = _getColorForTurno(c.turno);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirDialogoCurso(context, controller, curso: c),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Text(
                  c.paralelo, 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Turno ${c.turno}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              // Actions row (small)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    color: Colors.blue,
                    onPressed: () => _abrirDialogoCurso(context, controller, curso: c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 16),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    color: Colors.red,
                    onPressed: () => _confirmarEliminar(context, controller, c),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForTurno(String turno) {
    switch (turno.toUpperCase()) {
      case 'MANANA': case 'MAÑANA': return Colors.orange.shade700;
      case 'TARDE': return Colors.blue.shade700;
      case 'NOCHE': return Colors.indigo.shade700;
      default: return Colors.grey.shade700;
    }
  }

  void _confirmarEliminar(BuildContext context, CursoController ctrl, Curso c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Curso'),
        content: Text('¿Eliminar ${c.nombreGrado} ${c.paralelo}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ctrl.eliminarCurso(c.idCurso);
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }

  void _abrirDialogoCurso(BuildContext parentContext, CursoController controller, {Curso? curso}) {
    showDialog(
      context: parentContext,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: _CursoDialog(curso: curso),
      ),
    );
  }
}

class _CursoDialog extends StatefulWidget {
  final Curso? curso;
  const _CursoDialog({this.curso});

  @override
  State<_CursoDialog> createState() => _CursoDialogState();
}



class _CursoDialogState extends State<_CursoDialog> {
  final _formKey = GlobalKey<FormState>();
  final ConfiguracionParaleloService _configService = ConfiguracionParaleloService();
  
  Grado? _gradoSeleccionado;
  String? _paralelo;
  String _turno = 'MAÑANA';

  List<String> _paralelos = []; // Dynamic list
  bool _loadingParalelos = true;
  final List<String> _turnos = ['MAÑANA', 'TARDE', 'NOCHE'];

  @override
  void initState() {
    super.initState();
    _cargarParalelos();
    if (widget.curso != null) {
      final c = widget.curso!;
      _paralelo = c.paralelo;
      _turno = c.turno == 'MANANA' ? 'MAÑANA' : c.turno;
    }
  }

  Future<void> _cargarParalelos() async {
      try {
          final configs = await _configService.listar();
          if (mounted) {
              setState(() {
                  _paralelos = configs
                      .where((c) => c.activo)
                      .map((c) => c.nombre)
                      .toList();
                  _loadingParalelos = false;
                  
                  // Ensure existing parallel is in list if editing, even if inactive (edge case)
                  if (_paralelo != null && !_paralelos.contains(_paralelo)) {
                       _paralelos.add(_paralelo!);
                  }
              });
          }
      } catch (e) {
          // Fallback
          if (mounted) setState(() { 
              _paralelos = ['A', 'B', 'C'];
              _loadingParalelos = false; 
          });
      }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CursoController>();
    
    if (widget.curso != null && _gradoSeleccionado == null && controller.grados.isNotEmpty) {
      try {
        _gradoSeleccionado = controller.grados.firstWhere((g) => g.nombre == widget.curso!.nombreGrado);
      } catch (_) {}
    }

    return AlertDialog(
      title: Text(widget.curso == null ? 'Registrar Nuevo Curso' : 'Editar Curso'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Grado>(
                decoration: const InputDecoration(labelText: 'Grado'),
                value: _gradoSeleccionado,
                items: controller.grados.map((grado) {
                  return DropdownMenuItem(
                    value: grado,
                    child: Text('${grado.nombre} (${grado.nivel})'),
                  );
                }).toList(),
                onChanged: widget.curso == null ? (value) => setState(() => _gradoSeleccionado = value) : null,
                validator: (value) => value == null ? 'Seleccione un grado' : null,
              ),
              const SizedBox(height: 16),
              _loadingParalelos 
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Paralelo'),
                    value: _paralelo,
                    items: _paralelos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (value) => setState(() => _paralelo = value),
                    validator: (value) => value == null ? 'Seleccione un paralelo' : null,
                  ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Turno'),
                value: _turno,
                items: _turnos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (value) => setState(() => _turno = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              String turnoEnvio = _turno == 'MAÑANA' ? 'MANANA' : _turno;
              
              bool exito;
              if (widget.curso == null) {
                exito = await controller.crearCurso(_gradoSeleccionado!.idGrado, _paralelo!, turnoEnvio);
              } else {
                exito = await controller.updateCurso(widget.curso!.idCurso, _gradoSeleccionado!.idGrado, _paralelo!, turnoEnvio);
              }
              
              if (exito && mounted) Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
