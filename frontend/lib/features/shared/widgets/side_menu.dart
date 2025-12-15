import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../state/auth_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.rol?.toLowerCase() ?? '';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(role.toUpperCase()),
            accountEmail: const Text('Usuario autenticado'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _createDrawerItem(
                  icon: Icons.home,
                  text: 'Inicio',
                  onTap: () {
                    context.pop(); // Cierra el drawer
                    _navigateToHome(context, role);
                  },
                ),
                if (role == 'director' || role == 'admin') ..._buildDirectorItems(context),
                if (role == 'secretaria') ..._buildSecretariaItems(context),
                if (role == 'profesor') ..._buildProfesorItems(context),
                if (role == 'alumno' || role == 'estudiante') ..._buildEstudianteItems(context),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              context.pop();
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context, String role) {
    if (role == 'director' || role == 'admin') context.go('/dashboard-director');
    if (role == 'secretaria') context.go('/dashboard-secretaria');
    if (role == 'profesor') context.go('/dashboard-profesor');
    if (role == 'alumno' || role == 'estudiante') context.go('/dashboard-estudiante');
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  List<Widget> _buildDirectorItems(BuildContext context) {
    return [
      _createDrawerItem(icon: Icons.school, text: 'Profesores', onTap: () => context.go('/dashboard-director/profesores')),
      _createDrawerItem(icon: Icons.people, text: 'Estudiantes', onTap: () => context.go('/dashboard-director/estudiantes')),
      _createDrawerItem(icon: Icons.book, text: 'Cursos', onTap: () => context.go('/dashboard-director/cursos')),
      _createDrawerItem(icon: Icons.subject, text: 'Materias', onTap: () => context.go('/dashboard-director/materias')),
      _createDrawerItem(icon: Icons.schedule, text: 'Horarios', onTap: () => context.go('/dashboard-director/horarios')),
      _createDrawerItem(icon: Icons.payment, text: 'Pagos', onTap: () => context.go('/dashboard-director/pagos')),
      _createDrawerItem(icon: Icons.account_balance_wallet, text: 'Tipos de Pensión', onTap: () => context.go('/dashboard-director/tipo-pension')),
    ];
  }

  List<Widget> _buildSecretariaItems(BuildContext context) {
    return [
      _createDrawerItem(icon: Icons.people, text: 'Estudiantes', onTap: () => context.go('/dashboard-secretaria/estudiantes')),
      _createDrawerItem(icon: Icons.how_to_reg, text: 'Inscripciones', onTap: () => context.go('/dashboard-secretaria/inscripciones')),
      _createDrawerItem(icon: Icons.payment, text: 'Pagos', onTap: () => context.go('/dashboard-secretaria/pagos')),
      _createDrawerItem(icon: Icons.receipt, text: 'Comprobantes', onTap: () => context.go('/dashboard-secretaria/comprobantes')),
    ];
  }

  List<Widget> _buildProfesorItems(BuildContext context) {
    return [
      _createDrawerItem(icon: Icons.class_, text: 'Mis Cursos', onTap: () => context.go('/dashboard-profesor/cursos')),
      _createDrawerItem(icon: Icons.schedule, text: 'Horario', onTap: () => context.go('/dashboard-profesor/horarios')),
      _createDrawerItem(icon: Icons.grade, text: 'Notas', onTap: () => context.go('/dashboard-profesor/notas')),
    ];
  }

  List<Widget> _buildEstudianteItems(BuildContext context) {
    return [
      _createDrawerItem(icon: Icons.grade, text: 'Mis Notas', onTap: () => context.go('/dashboard-estudiante/notas')),
      _createDrawerItem(icon: Icons.schedule, text: 'Horario', onTap: () => context.go('/dashboard-estudiante/horarios')),
      _createDrawerItem(icon: Icons.payment, text: 'Mis Pagos', onTap: () => context.go('/dashboard-estudiante/pagos')),
    ];
  }
}
