import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.checkAuthOnStart();

    if (!auth.isAuthenticated) {
      context.go('/login');
    } else {
      final rol = auth.rol?.toLowerCase();
      switch (rol) {
        case 'director':
          context.go('/dashboard-director');
          break;
        case 'profesor':
          context.go('/dashboard-profesor');
          break;
        case 'alumno':
          context.go('/dashboard-alumno');
          break;
        case 'secretaria':
          context.go('/dashboard-secretaria');
          break;
        default:
          context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
