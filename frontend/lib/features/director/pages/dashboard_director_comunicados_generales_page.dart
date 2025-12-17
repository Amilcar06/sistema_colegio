import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../controller/comunicado_controller.dart';
import '../../comunicacion/models/comunicado.dart';

class DashboardDirectorComunicadosGeneralesPage extends StatelessWidget {
  const DashboardDirectorComunicadosGeneralesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComunicadoController()..cargarComunicados(),
      child: const _ComunicadosView(),
    );
  }
}

class _ComunicadosView extends StatefulWidget {
  const _ComunicadosView();

  @override
  State<_ComunicadosView> createState() => _ComunicadosViewState();
}

class _ComunicadosViewState extends State<_ComunicadosView> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ComunicadoController>();

    return MainScaffold(
      title: 'Comunicados Generales',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogo(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      child: controller.cargando
          ? const Center(child: CircularProgressIndicator())
          : controller.comunicados.isEmpty
              ? const Center(child: Text('No hay comunicados generales publicados.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.comunicados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final com = controller.comunicados[index];
                    return _buildComunicadoCard(context, com);
                  },
                ),
    );
  }

  Widget _buildComunicadoCard(BuildContext context, Comunicado com) {
    final colorPrioridad = _getColorPrioridad(com.prioridad);
    final isProfe = com.nombreAutor.contains('Prof'); // Simple check, or assume all are editable by Director for now

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorPrioridad.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorPrioridad.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorPrioridad),
                  ),
                  child: Text(
                    com.prioridad,
                    style: TextStyle(color: colorPrioridad, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  _formatDate(com.fechaPublicacion),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              com.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              com.contenido,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      com.nombreAutor,
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                      onPressed: () => _mostrarDialogo(context, comunicado: com),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _confirmarEliminacion(context, com),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _getColorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'ALTA':
        return Colors.red;
      case 'MEDIA':
        return Colors.orange;
      case 'BAJA':
      default:
        return Colors.green;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  void _mostrarDialogo(BuildContext context, {Comunicado? comunicado}) {
    showDialog(
      context: context,
      builder: (ctx) => _ComunicadoDialog(
        controller: context.read<ComunicadoController>(),
        comunicado: comunicado,
      ),
    );
  }

  Future<void> _confirmarEliminacion(BuildContext context, Comunicado com) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Comunicado'),
        content: const Text('¿Está seguro de eliminar este comunicado?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final exito = await context.read<ComunicadoController>().eliminarComunicado(com.idComunicado);
      if (exito && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comunicado eliminado')));
      }
    }
  }
}

class _ComunicadoDialog extends StatefulWidget {
  final ComunicadoController controller;
  final Comunicado? comunicado;

  const _ComunicadoDialog({required this.controller, this.comunicado});

  @override
  State<_ComunicadoDialog> createState() => _ComunicadoDialogState();
}

class _ComunicadoDialogState extends State<_ComunicadoDialog> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _prioridad = 'MEDIA';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.comunicado != null) {
      _titleCtrl.text = widget.comunicado!.titulo;
      _contentCtrl.text = widget.comunicado!.contenido;
      _prioridad = widget.comunicado!.prioridad;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.comunicado == null ? 'Nuevo Comunicado' : 'Editar Comunicado'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              decoration: const InputDecoration(labelText: 'Contenido', border: OutlineInputBorder()),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _prioridad,
              decoration: const InputDecoration(labelText: 'Prioridad', border: OutlineInputBorder()),
              items: ['BAJA', 'MEDIA', 'ALTA']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _prioridad = v!),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.comunicado == null ? 'Publicar' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete todos los campos')));
      return;
    }

    setState(() => _saving = true);

    final data = {
      'titulo': _titleCtrl.text,
      'contenido': _contentCtrl.text,
      'prioridad': _prioridad,
      'tipoDestinatario': 'TODOS', 
      'idReferencia': null
    };

    bool exito;
    if (widget.comunicado == null) {
      exito = await widget.controller.crearComunicado(data);
    } else {
      exito = await widget.controller.actualizarComunicado(widget.comunicado!.idComunicado, data);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.comunicado == null ? 'Publicado' : 'Actualizado')),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.controller.errorMessage ?? 'Error')));
      }
    }
  }
}
