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
                          final initials = '${e.nombres.isNotEmpty ? e.nombres[0] : ""}${e.apellidoPaterno.isNotEmpty ? e.apellidoPaterno[0] : ""}';
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
                                  '${e.nombres} ${e.apellidoPaterno} ${e.apellidoMaterno ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('CI: ${e.ci}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(e.correo, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                       decoration: BoxDecoration(
                                         color: Colors.blue.shade50,
                                         borderRadius: BorderRadius.circular(4),
                                         border: Border.all(color: Colors.blue.shade200)
                                       ),
                                       child: Text('ESTUDIANTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                    )
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: e.estado,
                                        activeColor: Colors.green,
                                        onChanged: (nuevoEstado) async {
                                          await ctrl.cambiarEstado(e, nuevoEstado);
                                        },
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                           _abrirFormularioEdicion(context, e);
                                        } else if (value == 'delete') {
                                           final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('¿Eliminar estudiante?'),
                                                content: Text('Esto eliminará también al usuario asociado (${e.correo})'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                                  ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await ctrl.eliminarEstudiante(e.idEstudiante);
                                              if(context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estudiante eliminado')));
                                              }
                                            }
                                        } else if (value == 'details') {
                                           ctrl.verDetallesEstudiante(e.idEstudiante, context);
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
