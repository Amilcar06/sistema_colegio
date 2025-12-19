import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/side_menu.dart';
import '../models/dashboard_profesor_stats.dart';
import '../services/profesor_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
    initializeDateFormatting('es');
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
          }
          
          final stats = snapshot.data ?? DashboardProfesorStats(totalCursos: 0, totalEstudiantes: 0, clasesHoy: 0);
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeBanner(context),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Agenda / Next Class
                      _buildAgendaCard(context, stats),
                      const SizedBox(height: 20),
                      
                      const Text('Acciones Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildQuickActions(context),
                      const SizedBox(height: 20),

                      const Text('Resumen General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildStatsGrid(context, stats),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d \u0027de\u0027 MMMM', 'es').format(now);
    final greeting = now.hour < 12 ? 'Buenos días' : now.hour < 18 ? 'Buenas tardes' : 'Buenas noches';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr.toUpperCase(),
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            '$greeting, Profesor',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Organiza tu día académico',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaCard(BuildContext context, DashboardProfesorStats stats) {
    // Determine status based on "Clases Hoy"
    final hasClasses = stats.clasesHoy > 0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: hasClasses 
                ? [Colors.orange.shade50, Colors.white] 
                : [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: hasClasses ? Colors.orange.shade100 : Colors.green.shade100,
                 shape: BoxShape.circle,
               ),
               child: Icon(
                 hasClasses ? Icons.access_time_filled : Icons.check_circle, 
                 color: hasClasses ? Colors.orange.shade800 : Colors.green.shade800,
                 size: 32,
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     hasClasses ? 'Tu Agenda Hoy' : 'Día Libre',
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     hasClasses 
                       ? 'Tienes ${stats.clasesHoy} clases programadas.' 
                       : 'No tienes clases programadas para hoy.',
                     style: TextStyle(color: Colors.grey.shade700),
                   ),
                   if (hasClasses)
                     Padding(
                       padding: const EdgeInsets.only(top: 8),
                       child: InkWell(
                         onTap: () => context.push('/dashboard-profesor/horarios'),
                         child: Text(
                           'Ver Horario Completo >',
                           style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                         ),
                       ),
                     ),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionBtn(context, 'Mis Cursos', Icons.menu_book, Colors.blue, '/dashboard-profesor/cursos'),
          const SizedBox(width: 12),
          _buildQuickActionBtn(context, 'Horario', Icons.calendar_today, Colors.purple, '/dashboard-profesor/horarios'),
          const SizedBox(width: 12),
          _buildQuickActionBtn(context, 'Avisos', Icons.campaign, Colors.red, '/dashboard-profesor/comunicados'),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, String label, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardProfesorStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context: context,
          title: 'Estudiantes',
          value: stats.totalEstudiantes.toString(),
          icon: Icons.people_outline,
          color: Colors.teal,
        ),
        _buildStatCard(
          context: context,
          title: 'Asignaturas',
          value: stats.totalCursos.toString(),
          icon: Icons.class_outlined,
          color: Colors.indigo,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }
}
