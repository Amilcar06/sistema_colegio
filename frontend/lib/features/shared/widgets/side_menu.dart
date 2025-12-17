import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../state/auth_provider.dart';

import '../../../shared/widgets/menu/menu_items.dart'; // Import menu definitions

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final rawRole = auth.rol?.toLowerCase() ?? '';
    
    // Normalize role for menu lookup
    String roleKey = rawRole;
    if (rawRole == 'admin') roleKey = 'director';
    if (rawRole == 'alumno') roleKey = 'estudiante';

    final menuItems = menuPorRol[roleKey] ?? [];

    return Drawer(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.pop(); // Cerrar drawer
              context.push('/perfil');
            },
            child: UserAccountsDrawerHeader(
              accountName: Text(rawRole.toUpperCase()),
              accountEmail: const Text('Usuario autenticado (Tap para ver perfil)'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
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
                    _navigateToHome(context, roleKey);
                  },
                ),
                ...menuItems.map((item) {
                  if (item is MenuHeader) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  } else if (item is MenuItem) {
                    return _createDrawerItem(
                      icon: item.icon,
                      text: item.label,
                      onTap: () {
                         context.pop(); // Close drawer
                         context.go(item.route);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const Divider(),
                _createDrawerItem(
                  icon: Icons.notifications,
                  text: 'Notificaciones',
                  onTap: () {
                    context.pop();
                    context.push('/notificaciones');
                  },
                ),
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
    if (role == 'director') context.go('/dashboard-director');
    if (role == 'secretaria') context.go('/dashboard-secretaria');
    if (role == 'profesor') context.go('/dashboard-profesor');
    if (role == 'estudiante') context.go('/dashboard-estudiante');
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
}    
