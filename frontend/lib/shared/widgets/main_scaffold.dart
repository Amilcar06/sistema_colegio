import 'package:flutter/material.dart';
import '../../state/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../features/shared/widgets/side_menu.dart';
import '../widgets/bottom_nav.dart';
import 'menu/menu_items.dart'; // define menuPorRol

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String? title;

  const MainScaffold({required this.child, this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final rol = context.read<AuthProvider>().rol ?? 'alumno';
    final menu = menuPorRol[rol] ?? [];

    final isAdmin = rol == 'director' || rol == 'secretaria' || rol == 'admin';

    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Portal Educativo')),
      drawer: const SideMenu(), 
      // bottomNavigationBar: ... (Disabled to use SideMenu consistently)
      body: child,
    );
  }
}
