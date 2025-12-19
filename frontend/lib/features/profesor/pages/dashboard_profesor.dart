import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/side_menu.dart';
import '../models/dashboard_profesor_stats.dart';
import '../services/profesor_service.dart';

class DashboardProfesor extends StatefulWidget {
  const DashboardProfesor({super.key});

  @override
  State<DashboardProfesor> createState() => _DashboardProfesorState();
}

class _DashboardProfesorState extends State<DashboardProfesor> {
  late Future<DashboardProfesorStats> _statsFuture;
  final _profesorService = ProfesorService();

  @override
  void initState() {
    super.initState();
    _statsFuture = _profesorService.getDashboardStats();
  }

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
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<DashboardProfesorStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          final stats = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido, Profesor',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildStatsGrid(stats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(DashboardProfesorStats stats) {
    return GridView.count(
      crossAxisCount: 2, // Simple 2 columns
      childAspectRatio: 1.5,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context: context,
          title: 'Mis Cursos',
          value: stats.totalCursos.toString(),
          icon: Icons.class_,
          color: Colors.blue,
          route: '/dashboard-profesor/cursos',
        ),
        _buildStatCard(
          context: context,
          title: 'Estudiantes',
          value: stats.totalEstudiantes.toString(),
          icon: Icons.people,
          color: Colors.orange,
          // TODO: Ruta a estudiantes o usar la de cursos
          route: '/dashboard-profesor/cursos', 
        ),
        _buildStatCard(
          context: context,
          title: 'Clases Hoy',
          value: stats.clasesHoy.toString(),
          icon: Icons.schedule,
          color: Colors.green,
          route: '/dashboard-profesor/horarios',
        ),
        // Placeholder for future warnings/notices
        _buildStatCard(
          context: context,
          title: 'Avisos',
          value: '0',
          icon: Icons.notifications,
          color: Colors.red,
          route: '/dashboard-profesor/comunicados',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: route != null ? () => context.push(route) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 5),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
