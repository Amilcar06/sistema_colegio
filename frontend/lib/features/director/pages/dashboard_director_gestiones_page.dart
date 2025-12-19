import 'package:flutter/material.dart';
import '../services/gestion_service.dart';
import '../../../shared/widgets/main_scaffold.dart';

class DashboardDirectorGestionesPage extends StatefulWidget {
  const DashboardDirectorGestionesPage({super.key});

  @override
  State<DashboardDirectorGestionesPage> createState() => _DashboardDirectorGestionesPageState();
}

class _DashboardDirectorGestionesPageState extends State<DashboardDirectorGestionesPage> {
  final GestionService _service = GestionService();
  List<Gestion> _gestiones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGestiones();
  }

  Future<void> _loadGestiones() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAll();
      setState(() {
        _gestiones = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _crearGestion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Gestión Académica'),
        content: const Text('Se creará una gestión para el año actual en el servidor.\n¿Desea continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.create();
        _loadGestiones();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gestión creada exitosamente')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _cambiarEstado(Gestion g, bool nuevoEstado) async {
    try {
      await _service.update(g.idGestion, g.anio, nuevoEstado);
      _loadGestiones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado correctamente')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _eliminar(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gestión'),
        content: const Text('¿Está seguro de eliminar esta gestión? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.delete(id);
        _loadGestiones();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gestión eliminada')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Gestiones Académicas',
      floatingActionButton: FloatingActionButton(
        onPressed: _crearGestion,
        child: const Icon(Icons.add),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gestiones.isEmpty
              ? const Center(child: Text('No hay gestiones registradas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _gestiones.length,
                  itemBuilder: (context, index) {
                    final g = _gestiones[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today, 
                          color: g.activa ? Colors.blue : Colors.grey
                        ),
                        title: Text('Gestión ${g.anio}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(g.activa ? 'Estado: Activa (Abierta)' : 'Estado: Cerrada'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: g.activa,
                              onChanged: (val) => _cambiarEstado(g, val),
                              activeColor: Colors.green,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _eliminar(g.idGestion),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
