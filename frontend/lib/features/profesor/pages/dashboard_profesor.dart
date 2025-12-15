import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/side_menu.dart';

class DashboardProfesor extends StatelessWidget {
  const DashboardProfesor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Dashboard Profesor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              // Lógica para cerrar sesión
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout(); // Borra el token y el rol
              context.go('/login'); // Redirige al login
            },
          ),
        ],
      ),
      body: const Center(child: Text('Pantalla de Profesor')),
    );
  }
}
