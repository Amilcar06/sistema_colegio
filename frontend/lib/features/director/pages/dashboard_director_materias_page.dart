import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../controller/materia_controller.dart';

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

class _MateriasView extends StatelessWidget {
  const _MateriasView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MateriaController>();

    return MainScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gestión de Materias',
                    style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  onPressed: () => _abrirDialogoCrear(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Materia'),
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
                itemCount: controller.materias.length,
                itemBuilder: (context, index) {
                  final materia = controller.materias[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(materia.nombre.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(materia.nombre),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => controller.eliminarMateria(materia.idMateria),
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

  void _abrirDialogoCrear(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (_) => ChangeNotifierProvider.value(
        value: parentContext.read<MateriaController>(),
        child: const _CrearMateriaDialog(),
      ),
    );
  }
}

class _CrearMateriaDialog extends StatefulWidget {
  const _CrearMateriaDialog();

  @override
  State<_CrearMateriaDialog> createState() => _CrearMateriaDialogState();
}

class _CrearMateriaDialogState extends State<_CrearMateriaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MateriaController>();

    return AlertDialog(
      title: const Text('Registrar Nueva Materia'),
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
              final exito = await controller.crearMateria(_nombreController.text);
              if (exito && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Materia creada exitosamente')),
                );
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
