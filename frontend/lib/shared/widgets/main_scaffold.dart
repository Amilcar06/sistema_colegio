import 'package:flutter/material.dart';
import '../../state/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../features/shared/widgets/side_menu.dart';
import '../widgets/bottom_nav.dart';
import 'menu/menu_items.dart'; // define menuPorRol

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom; // Added bottom parameter

  const MainScaffold({
    required this.child, 
    this.title, 
    this.actions, 
    this.floatingActionButton,
    this.bottom,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final rol = context.read<AuthProvider>().rol ?? 'estudiante';
    // final menu = menuPorRol[rol] ?? []; // Unused variable warning clean up check? keeping it simple.

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Portal Educativo'),
        actions: actions,
        bottom: bottom,
      ),
      drawer: const SideMenu(), 
      floatingActionButton: floatingActionButton,
      body: child,
    );
  }
}
