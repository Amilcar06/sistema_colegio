import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../controller/materia_controller.dart';
import '../models/materia.dart';

class DashboardDirectorMateriasPage extends StatelessWidget {
  const DashboardDirectorMateriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MateriaController(),
      child: const _MateriasView(),
    );
  }
}

class _MateriasView extends StatefulWidget {
  const _MateriasView();

  @override
  State<_MateriasView> createState() => _MateriasViewState();
}

class _MateriasViewState extends State<_MateriasView> {
  TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MateriaController>();
    
    // Filter logic
    final materiasFiltradas = controller.materias.where((m) => 
      m.nombre.toLowerCase().contains(_filter.toLowerCase())
    ).toList();

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
                      labelText: 'Buscar materia...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _abrirDialogoMateria(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Materia'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
          ),
          if (controller.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (controller.errorMessage != null)
            Expanded(
                child: Center(
                    child: Text('Error: ${controller.errorMessage}',
                        style: const TextStyle(color: Colors.red))))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: materiasFiltradas.length,
                itemBuilder: (context, index) {
                  final materia = materiasFiltradas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(materia.nombre.isNotEmpty ? materia.nombre.substring(0, 1).toUpperCase() : '?'),
                      ),
                      title: Text(materia.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _abrirDialogoMateria(context, materia: materia),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _confirmarEliminar(context, controller, materia),
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
    );
  }

  void _confirmarEliminar(BuildContext context, MateriaController ctrl, Materia m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Materia'),
        content: Text('¿Está seguro de eliminar "${m.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ctrl.eliminarMateria(m.idMateria);
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }

  void _abrirDialogoMateria(BuildContext parentContext, {Materia? materia}) {
    showDialog(
      context: parentContext,
      builder: (_) => ChangeNotifierProvider.value(
        value: parentContext.read<MateriaController>(),
        child: _MateriaDialog(materia: materia),
      ),
    );
  }
}

class _MateriaDialog extends StatefulWidget {
  final Materia? materia;
  const _MateriaDialog({this.materia});

  @override
  State<_MateriaDialog> createState() => _MateriaDialogState();
}

class _MateriaDialogState extends State<_MateriaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.materia?.nombre ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MateriaController>();
    final isEditing = widget.materia != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Materia' : 'Registrar Nueva Materia'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(labelText: 'Nombre de la Materia'),
          validator: (value) =>
              value == null || value.isEmpty ? 'Ingrese un nombre' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              bool exito;
              if (isEditing) {
                exito = await controller.updateMateria(widget.materia!.idMateria, _nombreController.text);
              } else {
                exito = await controller.crearMateria(_nombreController.text);
              }
              
              if (exito && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEditing ? 'Materia actualizada' : 'Materia creada')),
                );
              }
            }
          },
          child: Text(isEditing ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}
