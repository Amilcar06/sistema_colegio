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

    // Get current path to highlight active menu item
    final String currentPath = GoRouterState.of(context).uri.path;

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
              decoration: BoxDecoration(
                color: Colors.blue[900], // Updated color for better aesthetics
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
                  isActive: _isHomeActive(currentPath, roleKey),
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
                      isActive: currentPath == item.route,
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
                  isActive: currentPath == '/notificaciones',
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

  bool _isHomeActive(String currentPath, String role) {
    if (role == 'director' && currentPath == '/dashboard-director') return true;
    if (role == 'secretaria' && currentPath == '/dashboard-secretaria') return true;
    if (role == 'profesor' && currentPath == '/dashboard-profesor') return true;
    if (role == 'estudiante' && currentPath == '/dashboard-estudiante') return true;
    return false;
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
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? Colors.blue[900] : Colors.grey[700],
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.blue[900] : Colors.grey[800],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners for active item
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      onTap: onTap,
    );
  }
}    
