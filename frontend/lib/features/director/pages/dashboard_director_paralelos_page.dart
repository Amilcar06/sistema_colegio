import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/curso_controller.dart';
import '../../../shared/widgets/main_scaffold.dart';

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
  // Simulación de configuración
  final Set<String> _habilitados = {'A', 'B', 'C'};

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
                      
                  // Tab 2: Configuración (Dummy implementation kept)
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 8, // A-H
                    itemBuilder: (context, index) {
                      final p = String.fromCharCode(65 + index); // A, B, C...
                      final isEnabled = _habilitados.contains(p);
                      return InkWell(
                        onTap: () => setState(() {
                          if (isEnabled) _habilitados.remove(p); else _habilitados.add(p);
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isEnabled ? Colors.green : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isEnabled ? Colors.green : Colors.grey),
                          ),
                          child: Center(
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isEnabled ? Colors.white : Colors.black54,
                              ),
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
