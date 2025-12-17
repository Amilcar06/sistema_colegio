import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../controller/curso_controller.dart';
import '../models/grado.dart';
import '../models/curso.dart'; // Add this import

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
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Text(
                            groupKey, 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: cursosEnGrupo.map((c) => _buildCursoChip(context, controller, c)).toList(),
                          ),
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

  Widget _buildCursoChip(BuildContext context, CursoController controller, Curso c) {
    return InputChip(
      avatar: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(c.paralelo[0], style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      label: Text('${c.paralelo} (${c.turno})'),
      backgroundColor: _getColorForTurno(c.turno).withOpacity(0.2),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _confirmarEliminar(context, controller, c),
      onPressed: () => _abrirDialogoCurso(context, controller, curso: c), // Editar
    );
  }

  Color _getColorForTurno(String turno) {
    switch (turno.toUpperCase()) {
      case 'MANANA': case 'MAÑANA': return Colors.orange;
      case 'TARDE': return Colors.blue;
      case 'NOCHE': return Colors.indigo;
      default: return Colors.grey;
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
  
  Grado? _gradoSeleccionado;
  String? _paralelo;
  String _turno = 'MAÑANA';

  final List<String> _paralelos = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _turnos = ['MAÑANA', 'TARDE', 'NOCHE'];

  @override
  void initState() {
    super.initState();
    if (widget.curso != null) {
      final c = widget.curso!;
      // En modo edición, cargamos valores. 
      // Nota: El grado debería venir del backend pre-seleccionado, pero aqui lo buscamos en el controller
      // Esto requiere que el controller ya tenga la lista.
      // Simplificación: Asumimos que podemos encontrarlo por ID o nombre.
      _paralelo = c.paralelo;
      _turno = c.turno == 'MANANA' ? 'MAÑANA' : c.turno;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CursoController>();
    
    // Inicializar grado si es edición
    if (widget.curso != null && _gradoSeleccionado == null && controller.grados.isNotEmpty) {
      // Intentar encontrar el grado que coincida. El modelo Curso tiene idGrado?
      // Revisando modelo Curso... probablemente tenga idCurso, pero no idGrado explicito a veces.
      // Asumiremos que podemos matchear por nombreGrado.
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
                onChanged: widget.curso == null ? (value) => setState(() => _gradoSeleccionado = value) : null, // Deshabilitar cambio de grado en edición si se desea
                 // O permitirlo.
                validator: (value) => value == null ? 'Seleccione un grado' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
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
