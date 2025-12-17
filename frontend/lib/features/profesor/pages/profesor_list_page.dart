import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/profesor_controller.dart';
import '../models/profesor_response.dart';
import '../../shared/widgets/registro_profesor_form.dart';

class ProfesorListWrapper extends StatelessWidget {
  const ProfesorListWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfesorController()..cargarProfesores(),
      child: const ProfesorListPage(),
    );
  }
}

class ProfesorListPage extends StatefulWidget {
  const ProfesorListPage({super.key});

  @override
  State<ProfesorListPage> createState() => _ProfesorListPageState();
}

class _ProfesorListPageState extends State<ProfesorListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirFormularioNuevoProfesor(BuildContext context) {
    final controller = context.read<ProfesorController>();
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
            child: const RegistroProfesorForm(),
          );
        },
      ),
    );
  }

  void _abrirFormularioEdicion(BuildContext context, ProfesorResponseDTO profesor) {
    final controller = context.read<ProfesorController>();
    controller.seleccionarParaEdicion(profesor);

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
            child: const RegistroProfesorForm(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profesores')),
      body: Consumer<ProfesorController>(
        builder: (context, ctrl, _) {
          if (ctrl.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.errorMessage != null) {
            return Center(child: Text('Error: ${ctrl.errorMessage}', style: const TextStyle(color: Colors.red)));
          }

          if (ctrl.profesores.isEmpty) {
            return const Center(child: Text('No hay profesores registrados.'));
          }

          // Filtrado local
          final filtrados = ctrl.profesores.where((p) {
            final query = _searchQuery.toLowerCase();
            final nombreCompleto = '${p.nombres} ${p.apellidoPaterno} ${p.apellidoMaterno ?? ''}'.toLowerCase();
            final ci = p.ci.toLowerCase();
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
                          final p = filtrados[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.school)),
                              title: Text('${p.nombres} ${p.apellidoPaterno} ${p.apellidoMaterno ?? ''}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CI: ${p.ci}'),
                                  Text('Correo: ${p.correo}'),
                                  Text('Rol: PROFESOR'),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  Switch(
                                    value: p.estado,
                                    onChanged: (nuevoEstado) async {
                                      await ctrl.cambiarEstado(p, nuevoEstado);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.blue),
                                    tooltip: 'Ver detalles',
                                    onPressed: () => ctrl.verDetallesProfesor(p.idProfesor, context),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _abrirFormularioEdicion(context, p),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('¿Eliminar profesor?'),
                                          content: Text('Esto eliminará también al usuario asociado (${p.correo})'),
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
                                        await ctrl.eliminarProfesor(p.idProfesor);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Profesor eliminado')),
                                        );
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
        onPressed: () => _abrirFormularioNuevoProfesor(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
