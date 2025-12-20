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
                          final initials = '${u.nombres.isNotEmpty ? u.nombres[0] : ""}${u.apellidoPaterno.isNotEmpty ? u.apellidoPaterno[0] : ""}';
                          final color = _getColorForName(initials);

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.2),
                                  child: Text(
                                    initials.toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                                  ),
                                ),
                                title: Text(
                                  '${u.nombres} ${u.apellidoPaterno} ${u.apellidoMaterno ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(u.correo, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                       margin: const EdgeInsets.only(top: 4),
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                       decoration: BoxDecoration(
                                         color: Colors.grey.shade200,
                                         borderRadius: BorderRadius.circular(4)
                                       ),
                                       child: Text(u.rol.nombre, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Estado toggle compact
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: u.estado,
                                        activeColor: Colors.green,
                                        onChanged: (nuevoEstado) async {
                                          await ctrl.cambiarEstado(u, nuevoEstado);
                                        },
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          _abrirFormularioEdicion(context, u);
                                        } else if (value == 'delete') {
                                           final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('¿Eliminar usuario?'),
                                                content: Text('Esto eliminará al usuario (${u.correo})'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                                  ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await ctrl.eliminarUsuario(u.idUsuario);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
                                              }
                                            }
                                        } else if (value == 'details') {
                                           ctrl.verDetallesUsuario(u.idUsuario, context);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'details',
                                          child: ListTile(leading: Icon(Icons.info_outline), title: Text('Detalles'), contentPadding: EdgeInsets.zero, dense: true),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: ListTile(leading: Icon(Icons.edit, color: Colors.orange), title: Text('Editar'), contentPadding: EdgeInsets.zero, dense: true),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Eliminar'), contentPadding: EdgeInsets.zero, dense: true),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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

  Color _getColorForName(String text) {
    if (text.isEmpty) return Colors.blue;
    final hash = text.codeUnits.fold(0, (p, c) => p + c);
    final colors = [
      Colors.blue.shade700, Colors.red.shade700, Colors.green.shade700, 
      Colors.orange.shade700, Colors.purple.shade700, Colors.teal.shade700
    ];
    return colors[hash % colors.length];
  }
}
