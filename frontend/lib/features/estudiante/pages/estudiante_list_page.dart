import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/estudiante_controller.dart';
import '../models/estudiante_response.dart';
import '../../shared/widgets/registro_estudiante_form.dart';

class EstudianteListWrapper extends StatelessWidget {
  const EstudianteListWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstudianteController()..cargarEstudiantes(),
      child: const EstudianteListPage(),
    );
  }
}

class EstudianteListPage extends StatefulWidget {
  const EstudianteListPage({super.key});

  @override
  State<EstudianteListPage> createState() => _EstudianteListPageState();
}

class _EstudianteListPageState extends State<EstudianteListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirFormularioNuevoEstudiante(BuildContext context) {
    final controller = context.read<EstudianteController>();
    controller.cancelarEdicion();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => ChangeNotifierProvider.value(
        value: controller,
        builder: (modalContext, _) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: const RegistroEstudianteForm(),
          );
        },
      ),
    );
  }

  void _abrirFormularioEdicion(BuildContext context, EstudianteResponseDTO estudiante) {
    final controller = context.read<EstudianteController>();
    controller.seleccionarParaEdicion(estudiante);

    Widget form;
    form = const RegistroEstudianteForm();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => ChangeNotifierProvider.value(
        value: controller,
        builder: (modalContext, _) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: form,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes')),
      body: Consumer<EstudianteController>(
        builder: (context, ctrl, _) {
          if (ctrl.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.estudiantes.isEmpty) {
            return const Center(child: Text('No hay estudiantes registrados.'));
          }

          // Filtrado local
          final filtrados = ctrl.estudiantes.where((e) {
            final query = _searchQuery.toLowerCase();
            final nombreCompleto = '${e.nombres} ${e.apellidoPaterno} ${e.apellidoMaterno ?? ''}'.toLowerCase();
            final ci = e.ci.toLowerCase();
            return nombreCompleto.contains(query) || ci.contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre o CI',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              Expanded(
                child: filtrados.isEmpty
                    ? const Center(child: Text('No se encontraron resultados.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtrados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final e = filtrados[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text('${e.nombres} ${e.apellidoPaterno} ${e.apellidoMaterno ?? ''}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CI: ${e.ci}'),
                                  Text('Correo: ${e.correo}'),
                                  Text('Rol: ESTUDIANTE'),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  Switch(
                                    value: e.estado,
                                    onChanged: (nuevoEstado) async {
                                      await ctrl.cambiarEstado(e, nuevoEstado);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.blue),
                                    tooltip: 'Ver detalles',
                                    onPressed: () => ctrl.verDetallesEstudiante(e.idEstudiante, context),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _abrirFormularioEdicion(context, e),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('¿Eliminar estudiante?'),
                                          content: Text('Esto eliminará también al usuario asociado (${e.correo})'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final exito = await ctrl.eliminarEstudiante(e.idEstudiante);
                                        if (exito) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Estudiante eliminado')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(ctrl.errorMessage ?? 'Error al eliminar')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioNuevoEstudiante(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
