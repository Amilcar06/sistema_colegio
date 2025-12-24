import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/profesor_controller.dart';
import '../models/profesor_response.dart';
import '../../shared/widgets/registro_profesor_form.dart';
import 'package:unidad_educatica_frontend/shared/widgets/infinite_scroll_paginator.dart';
import 'package:unidad_educatica_frontend/shared/models/page_response.dart';
import '../models/profesor_response.dart';

class ProfesorListWrapper extends StatefulWidget {
  const ProfesorListWrapper({super.key});

  @override
  State<ProfesorListWrapper> createState() => _ProfesorListWrapperState();
}

class _ProfesorListWrapperState extends State<ProfesorListWrapper> {
  @override
  @override
  void initState() {
    super.initState();
    // No explicit load in initState, Paginator handles it
  }

  @override
  Widget build(BuildContext context) {
    return const ProfesorListPage();
  }
}

class ProfesorListPage extends StatefulWidget {
  const ProfesorListPage({super.key});

  @override
  State<ProfesorListPage> createState() => _ProfesorListPageState();
}

class _ProfesorListPageState extends State<ProfesorListPage> {
  final GlobalKey<InfiniteScrollPaginatorState> _paginatorKey = GlobalKey();
  // removed search strings
  // final TextEditingController _searchController = TextEditingController();
  // String _searchQuery = '';

  @override
  void dispose() {
    // _searchController.dispose();
    super.dispose();
  }

  Future<void> _abrirFormularioNuevoProfesor(BuildContext context) async {
    final controller = context.read<ProfesorController>();
    controller.cancelarEdicion();

    await showModalBottomSheet(
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
    _paginatorKey.currentState?.refresh();
  }

  Future<void> _abrirFormularioEdicion(BuildContext context, ProfesorResponseDTO profesor) async {
    final controller = context.read<ProfesorController>();
    controller.seleccionarParaEdicion(profesor);

    await showModalBottomSheet(
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
      body: InfiniteScrollPaginator<ProfesorResponseDTO>(
        key: _paginatorKey,
        fetchPage: (page, size) => context.read<ProfesorController>().listarPaginated(page, size),
        itemBuilder: (context, p) {
          final initials = '${p.nombres.isNotEmpty ? p.nombres[0] : ""}${p.apellidoPaterno.isNotEmpty ? p.apellidoPaterno[0] : ""}';
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
                  '${p.nombres} ${p.apellidoPaterno} ${p.apellidoMaterno ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('CI: ${p.ci}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(p.correo, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.shade200)
                        ),
                        child: Text('PROFESOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                    )
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: p.estado,
                        activeColor: Colors.green,
                        onChanged: (nuevoEstado) async {
                          final ctrl = context.read<ProfesorController>();
                          await ctrl.cambiarEstado(p, nuevoEstado);
                          _paginatorKey.currentState?.refresh();
                        },
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        final ctrl = context.read<ProfesorController>();
                        if (value == 'edit') {
                            await _abrirFormularioEdicion(context, p);
                            _paginatorKey.currentState?.refresh();
                        } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('¿Eliminar profesor?'),
                                content: Text('Esto eliminará también al usuario asociado (${p.correo})'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                  ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final success = await ctrl.eliminarProfesor(p.idProfesor);
                              if(success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profesor eliminado')));
                                  _paginatorKey.currentState?.refresh();
                              }
                            }
                        } else if (value == 'details') {
                            ctrl.verDetallesProfesor(p.idProfesor, context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'details', child: ListTile(leading: Icon(Icons.info_outline), title: Text('Detalles'), dense: true, contentPadding: EdgeInsets.zero)),
                        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, color: Colors.orange), title: Text('Editar'), dense: true, contentPadding: EdgeInsets.zero)),
                        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Eliminar'), dense: true, contentPadding: EdgeInsets.zero)),
                      ]
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioNuevoProfesor(context),
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
