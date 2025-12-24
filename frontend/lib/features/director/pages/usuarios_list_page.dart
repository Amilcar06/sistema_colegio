import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/usuarios_controller.dart';
import '../../shared/widgets/registro_director_form.dart';
import '../../shared/widgets/registro_secretaria_form.dart';
import 'package:unidad_educatica_frontend/shared/widgets/infinite_scroll_paginator.dart';
import 'package:unidad_educatica_frontend/shared/models/page_response.dart';
import '../models/usuario_response.dart';
import '../models/usuario_response.dart';

class UsuariosListWrapper extends StatelessWidget {
  const UsuariosListWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsuarioController(), // Paginator will load
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
  final GlobalKey<InfiniteScrollPaginatorState> _paginatorKey = GlobalKey();
  // final TextEditingController _searchController = TextEditingController();
  // String _searchQuery = '';

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _abrirFormularioNuevoUsuario(BuildContext context) async {
    final controller = context.read<UsuarioController>();
    controller.limpiarSeleccion();

    await showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*ListTile( ... )*/
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Registrar Secretaria'),
            onTap: () async {
              Navigator.pop(context);
              await showModalBottomSheet(
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
              _paginatorKey.currentState?.refresh();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _abrirFormularioEdicion(BuildContext context, UsuarioResponseDTO usuario) async {
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

    await showModalBottomSheet(
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
    // Caller refreshes or we refresh here? Caller calls this and then refreshes.
    // So we just await here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: InfiniteScrollPaginator<UsuarioResponseDTO>(
        key: _paginatorKey,
        fetchPage: (page, size) => context.read<UsuarioController>().listarPaginated(page, size),
        itemBuilder: (context, u) {
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
                          final ctrl = context.read<UsuarioController>();
                          await ctrl.cambiarEstado(u, nuevoEstado);
                          _paginatorKey.currentState?.refresh();
                        },
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        final ctrl = context.read<UsuarioController>();
                        if (value == 'edit') {
                          await _abrirFormularioEdicion(context, u);
                          _paginatorKey.currentState?.refresh();
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
                              final success = await ctrl.eliminarUsuario(u.idUsuario); // This returns Future<void>, need to handle success?
                              // Controller implementation wraps in try/catch and sets errorMessage if fails.
                              // But it handles local list removal.
                              // We should perform a refresh to be safe or trust the controller/backend.
                              // Since controller removes from local list but Paginator maintains its own list, we MUST refresh Paginator.
                              // Controller notifies listeners, but InfiniteScrollPaginator keeps its own state unless forced to refresh.
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
                                _paginatorKey.currentState?.refresh();
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
