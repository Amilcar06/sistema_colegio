import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/curso_controller.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../models/configuracion_paralelo.dart';
import '../services/configuracion_paralelo_service.dart';

class DashboardDirectorParalelosPage extends StatelessWidget {
  const DashboardDirectorParalelosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CursoController(),
      child: const _ParalelosView(),
    );
  }
}

class _ParalelosView extends StatefulWidget {
  const _ParalelosView();

  @override
  State<_ParalelosView> createState() => _ParalelosViewState();
}

class _ParalelosViewState extends State<_ParalelosView> {
  final ConfiguracionParaleloService _configService = ConfiguracionParaleloService();
  List<ConfiguracionParalelo> _configuracion = [];
  bool _isLoadingConfig = true;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final data = await _configService.listar();
      if (mounted) {
        setState(() {
          _configuracion = data;
          _isLoadingConfig = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingConfig = false);
        // Silent error or snackbar
      }
    }
  }

  Future<void> _toggleParalelo(ConfiguracionParalelo p) async {
    // Optimistic update
    setState(() {
      final index = _configuracion.indexWhere((element) => element.id == p.id);
      if (index != -1) {
        // Create copy with inverted active status
        // Since attributes are final, we can't just set active.
        // But we are reloading anyway or should construct new object.
        // For simple feedback, we rely on reload or just waiting.
        // Actually, let's show loading or just wait.
      }
    });

    try {
        await _configService.toggleEstado(p.id, !p.activo);
        _cargarConfiguracion(); // Reload to be sure
    } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CursoController>();
    
    // Group courses by Parallel
    final Map<String, List<dynamic>> byParallel = {};
    for (var c in controller.cursos) {
      if (!byParallel.containsKey(c.paralelo)) byParallel[c.paralelo] = [];
      byParallel[c.paralelo]!.add(c);
    }
    final sortedParallels = byParallel.keys.toList()..sort();

    return MainScaffold(
      title: 'Gestión de Paralelos',
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Ver por Paralelo'),
                Tab(icon: Icon(Icons.settings), text: 'Configuración'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Listado
                  controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedParallels.length,
                        itemBuilder: (context, index) {
                          final p = sortedParallels[index];
                          final cursos = byParallel[p]!;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(child: Text(p)),
                              title: Text('Paralelo $p'),
                              subtitle: Text('${cursos.length} cursos asignados'),
                              children: cursos.map((c) => ListTile(
                                title: Text(c.nombreGrado), // Assume Curso object
                                subtitle: Text(c.turno),
                                leading: const Icon(Icons.school, size: 20),
                              )).toList(),
                            ),
                          );
                        },
                      ),
                      
                  // Tab 2: Configuración Real
                  _isLoadingConfig
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _configuracion.length,
                          itemBuilder: (context, index) {
                            final p = _configuracion[index];
                            final isEnabled = p.activo;
                            return InkWell(
                              onTap: () => _toggleParalelo(p),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isEnabled ? Colors.green : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isEnabled ? Colors.green : Colors.grey),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        p.nombre,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isEnabled ? Colors.white : Colors.black54,
                                        ),
                                      ),
                                      if (isEnabled)
                                        const Icon(Icons.check_circle, color: Colors.white, size: 16)
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
