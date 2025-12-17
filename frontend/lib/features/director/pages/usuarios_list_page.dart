import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/usuarios_controller.dart';
import '../../shared/widgets/registro_director_form.dart';
import '../../shared/widgets/registro_secretaria_form.dart';
import '../models/usuario_response.dart';

class UsuariosListWrapper extends StatelessWidget {
  const UsuariosListWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsuarioController()..cargarUsuarios(),
      child: const UsuariosListPage(),
    );
  }
}

class UsuariosListPage extends StatefulWidget {
  const UsuariosListPage({super.key});

  @override
  State<UsuariosListPage> createState() => _UsuariosListPageState();
}

class _UsuariosListPageState extends State<UsuariosListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirFormularioNuevoUsuario(BuildContext context) {
    final controller = context.read<UsuarioController>();
    controller.limpiarSeleccion();

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Registrar Director'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (modalContext) => ChangeNotifierProvider.value(
                  value: controller,
                  builder: (modalContext, _) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                    ),
                    child: const RegistroDirectorForm(),
                  ),
                ),
              );
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Registrar Secretaria'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (modalContext) => ChangeNotifierProvider.value(
                  value: controller,
                  builder: (modalContext, _) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                    ),
                    child: const RegistroSecretariaForm(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _abrirFormularioEdicion(BuildContext context, UsuarioResponseDTO usuario) {
    final controller = context.read<UsuarioController>();
    controller.seleccionarParaEdicion(usuario);

    Widget form;
    if (usuario.rol.nombre.toUpperCase() == 'DIRECTOR') {
      form = const RegistroDirectorForm();
    } else if (usuario.rol.nombre.toUpperCase() == 'SECRETARIA') {
      form = const RegistroSecretariaForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol no soportado para edición')),
      );
      return;
    }

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
      appBar: AppBar(title: const Text('Usuarios')),
      body: Consumer<UsuarioController>(
        builder: (context, ctrl, _) {
          if (ctrl.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.errorMessage != null) {
            return Center(child: Text(ctrl.errorMessage!));
          }

          if (ctrl.usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          // Filtrado local
          final filtrados = ctrl.usuarios.where((u) {
            final query = _searchQuery.toLowerCase();
            final nombreCompleto = '${u.nombres} ${u.apellidoPaterno} ${u.apellidoMaterno ?? ''}'.toLowerCase();
            final email = u.correo.toLowerCase();
            final rol = u.rol.nombre.toLowerCase();
            return nombreCompleto.contains(query) || email.contains(query) || rol.contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre, correo o rol',
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
                          final u = filtrados[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text('${u.nombres} ${u.apellidoPaterno} ${u.apellidoMaterno ?? ''}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Correo: ${u.correo}'),
                                  Text('Rol: ${u.rol.nombre}'),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  Switch(
                                    value: u.estado,
                                    onChanged: (nuevoEstado) async {
                                      await ctrl.cambiarEstado(u, nuevoEstado);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.blue),
                                    tooltip: 'Ver detalles',
                                    onPressed: () => ctrl.verDetallesUsuario(u.idUsuario, context),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _abrirFormularioEdicion(context, u),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('¿Eliminar usuario?'),
                                          content: Text('Esto eliminará al usuario (${u.correo})'),
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
                                        await ctrl.eliminarUsuario(u.idUsuario);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Usuario eliminado')),
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
        onPressed: () => _abrirFormularioNuevoUsuario(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
