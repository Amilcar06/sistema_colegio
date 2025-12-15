import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/side_menu.dart';

class DashboardDirector extends StatelessWidget {
  const DashboardDirector({super.key});

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