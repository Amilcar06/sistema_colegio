import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/asignacion_controller.dart';
import '../controller/curso_controller.dart';
import '../controller/materia_controller.dart';
import '../../profesor/controller/profesor_controller.dart';
import '../models/curso.dart';
import '../models/asignacion_docente.dart';
import '../../../shared/widgets/main_scaffold.dart';

class DashboardDirectorAsignacionesPage extends StatelessWidget {
  const DashboardDirectorAsignacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CursoController()..cargarCursos()),
        ChangeNotifierProvider(create: (_) => AsignacionController()),
        ChangeNotifierProvider(create: (_) => MateriaController()..cargarMaterias()),
        ChangeNotifierProvider(create: (_) => ProfesorController()..cargarProfesores()),
      ],
      child: const _AsignacionesView(),
    );
  }
}

class _AsignacionesView extends StatefulWidget {
  const _AsignacionesView();

  @override
  State<_AsignacionesView> createState() => _AsignacionesViewState();
}

class _AsignacionesViewState extends State<_AsignacionesView> {
  Curso? _cursoSeleccionado;

  @override
  Widget build(BuildContext context) {
    final cursoCtrl = context.watch<CursoController>();
    final asignacionCtrl = context.watch<AsignacionController>();

    return MainScaffold(
      title: 'Asignación Docente',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de Curso
            DropdownButtonFormField<Curso>(
              decoration: InputDecoration(
                labelText: 'Seleccione un Curso para gestionar asignaciones',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.class_),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              value: _cursoSeleccionado,
              items: cursoCtrl.cursos.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text('${c.nombreGrado} - ${c.paralelo}', style: const TextStyle(fontWeight: FontWeight.w500)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _cursoSeleccionado = val);
                if (val != null) {
                  context.read<AsignacionController>().cargarAsignaciones(val.idCurso);
                }
              },
            ),
            const SizedBox(height: 20),

            if (asignacionCtrl.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text(asignacionCtrl.errorMessage!, style: TextStyle(color: Colors.red[800])),
              ),

            // Lista de Asignaciones
            Expanded(
              child: asignacionCtrl.cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _cursoSeleccionado == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.arrow_upward, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Seleccione un curso arriba para comenzar', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        )
                      : asignacionCtrl.asignaciones.isEmpty
                          ? const Center(child: Text('No hay materias asignadas en este curso aún.'))
                          : ListView.separated(
                              itemCount: asignacionCtrl.asignaciones.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final a = asignacionCtrl.asignaciones[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4)),
                                      borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue.withOpacity(0.1),
                                          child: Icon(Icons.book, color: Theme.of(context).primaryColor),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                a.nombreMateria, 
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text('Docente: ${a.nombreProfesor}', style: TextStyle(color: Colors.grey.shade800)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(8),
                                          onPressed: () => _mostrarDialogoAsignacion(context, asignacion: a),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(8),
                                          onPressed: () => _confirmarEliminacion(context, a),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: _cursoSeleccionado != null
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarDialogoAsignacion(context),
              label: const Text('Asignar Materia'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _mostrarDialogoAsignacion(BuildContext parentContext, {AsignacionDocente? asignacion}) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return _AsignacionDialog(
          curso: _cursoSeleccionado!,
          parentContext: parentContext,
          asignacion: asignacion,
        );
      },
    );
  }

  Future<void> _confirmarEliminacion(BuildContext context, AsignacionDocente asignacion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Asignación'),
        content: Text('¿Está seguro de eliminar la asignación de ${asignacion.nombreMateria} a ${asignacion.nombreProfesor}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // ignore: use_build_context_synchronously
      final exito = await context.read<AsignacionController>().eliminarAsignacion(
            asignacion.idAsignacion,
            _cursoSeleccionado!.idCurso,
          );
      
      if (exito && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asignación eliminada correctamente')),
        );
      }
    }
  }
}

class _AsignacionDialog extends StatefulWidget {
  final Curso curso;
  final BuildContext parentContext;
  final AsignacionDocente? asignacion;

  const _AsignacionDialog({
    required this.curso,
    required this.parentContext,
    this.asignacion,
  });

  @override
  State<_AsignacionDialog> createState() => _AsignacionDialogState();
}

class _AsignacionDialogState extends State<_AsignacionDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _idMateriaSeleccionada;
  int? _idProfesorSeleccionado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.asignacion != null) {
      _idMateriaSeleccionada = widget.asignacion!.idMateria;
      _idProfesorSeleccionado = widget.asignacion!.idProfesor;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el contexto padre para acceder a los providers ya cargados
    final materias = widget.parentContext.read<MateriaController>().materias;
    final profesores = widget.parentContext.read<ProfesorController>().profesores;
    final esEdicion = widget.asignacion != null;

    return AlertDialog(
      title: Text(esEdicion ? 'Editar Asignación' : 'Asignar Docente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${widget.curso.nombreGrado} ${widget.curso.paralelo}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Materia', border: OutlineInputBorder()),
                value: _idMateriaSeleccionada,
                items: materias.map((m) {
                  return DropdownMenuItem(value: m.idMateria, child: Text(m.nombre));
                }).toList(),
                onChanged: (val) => setState(() => _idMateriaSeleccionada = val),
                validator: (val) => val == null ? 'Seleccione una materia' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Profesor', border: OutlineInputBorder()),
                value: _idProfesorSeleccionado,
                items: profesores.map((p) {
                  return DropdownMenuItem(
                      value: p.idProfesor,
                      child: Text('${p.nombres} ${p.apellidoPaterno}'));
                }).toList(),
                onChanged: (val) => setState(() => _idProfesorSeleccionado = val),
                 validator: (val) => val == null ? 'Seleccione un profesor' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _guardando = true);

    const int idGestionActual = 1; 

    bool exito;
    if (widget.asignacion != null) {
      // Editar
      exito = await widget.parentContext.read<AsignacionController>().actualizarAsignacion(
        widget.asignacion!.idAsignacion,
        widget.curso.idCurso,
        _idMateriaSeleccionada!,
        _idProfesorSeleccionado!,
        idGestionActual,
      );
    } else {
      // Crear
      exito = await widget.parentContext.read<AsignacionController>().crearAsignacion(
        widget.curso.idCurso,
        _idMateriaSeleccionada!,
        _idProfesorSeleccionado!,
        idGestionActual,
      );
    }

    if (mounted) {
      setState(() => _guardando = false);
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.asignacion != null ? 'Asignación actualizada' : 'Asignación creada')),
        );
      }
    }
  }
}
