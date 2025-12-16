import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/side_menu.dart';

import '../services/dashboard_service.dart';

class DashboardDirector extends StatefulWidget {
  const DashboardDirector({super.key});

  @override
  State<DashboardDirector> createState() => _DashboardDirectorState();
}

class _DashboardDirectorState extends State<DashboardDirector> {
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic> _stats = {
    'totalEstudiantes': 0,
    'totalProfesores': 0,
    'ingresosHoy': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final data = await _dashboardService.getStats();
      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Dashboard Director'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Panel de Control',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // KPI Cards
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(child: _StatCard(
                    title: 'Estudiantes',
                    value: _stats['totalEstudiantes'].toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    title: 'Profesores',
                    value: _stats['totalProfesores'].toString(),
                    icon: Icons.school,
                    color: Colors.orange,
                  )),
                ],
              ),
            const SizedBox(height: 10),
            if (!_isLoading)
               Row(
                children: [
                  Expanded(child: _StatCard(
                    title: 'Ingresos Hoy',
                    value: 'Bs ${_stats['ingresosHoy']}',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  )),
                ],
              ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3/2,
              children: [
                _DashboardButton(
                  icon: Icons.school,
                  label: 'Profesores',
                  route: '/dashboard-director/profesores',
                ),
                _DashboardButton(
                  icon: Icons.people,
                  label: 'Estudiantes',
                  route: '/dashboard-director/estudiantes',
                ),
                _DashboardButton(
                  icon: Icons.book,
                  label: 'Cursos',
                  route: '/dashboard-director/cursos',
                ),
                _DashboardButton(
                  icon: Icons.subject,
                  label: 'Materias',
                  route: '/dashboard-director/materias',
                ),
                _DashboardButton(
                  icon: Icons.assignment,
                  label: 'Asignaciones',
                  route: '/dashboard-director/asignaciones',
                ),
                _DashboardButton(
                  icon: Icons.schedule,
                  label: 'Horarios',
                  route: '/dashboard-director/horarios',
                ),
                _DashboardButton(
                  icon: Icons.event,
                  label: 'Eventos',
                  route: '/dashboard-director/eventos',
                ),
                _DashboardButton(
                  icon: Icons.announcement,
                  label: 'Comunicados Generales',
                  route: '/dashboard-director/comunicados-generales',
                ),
                _DashboardButton(
                  icon: Icons.message,
                  label: 'Comunicados Curso',
                  route: '/dashboard-director/comunicados-curso',
                ),
                _DashboardButton(
                  icon: Icons.payment,
                  label: 'Pagos',
                  route: '/dashboard-director/pagos',
                ),
                _DashboardButton(
                  icon: Icons.account_balance_wallet,
                  label: 'Tipo Pensión',
                  route: '/dashboard-director/tipo-pension',
                ),
                _DashboardButton(
                  icon: Icons.grade,
                  label: 'Notas',
                  route: '/dashboard-director/notas',
                ),
                _DashboardButton(
                  icon: Icons.person,
                  label: 'Usuarios',
                  route: '/dashboard-director/usuarios',
                ),
                _DashboardButton(
                  icon: Icons.how_to_reg,
                  label: 'Inscripciones',
                  route: '/dashboard-director/inscripciones',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             Icon(icon, size: 30, color: color),
             const SizedBox(height: 8),
             Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
             Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}