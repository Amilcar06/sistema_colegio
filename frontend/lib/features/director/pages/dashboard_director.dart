import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import '../../../state/auth_provider.dart';
import '../../shared/widgets/side_menu.dart';
import '../services/dashboard_service.dart';

class DashboardDirector extends StatefulWidget {
  const DashboardDirector({super.key});

  @override
  State<DashboardDirector> createState() => _DashboardDirectorState();
}

class _DashboardDirectorState extends State<DashboardDirector> {
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic> _stats = {
    'totalEstudiantes': 0,
    'totalProfesores': 0,
    'ingresosHoy': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final data = await _dashboardService.getStats();
      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeBanner(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   // Stats
                   if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                   else
                    _buildStatsRow(),
                   
                   const SizedBox(height: 24),
                   
                   // Sections
                   _buildSectionTitle('Gestión Académica'),
                   _buildGridAcademia(),
                   
                   const SizedBox(height: 20),
                   _buildSectionTitle('Comunidad & Usuarios'),
                   _buildGridComunidad(),

                   const SizedBox(height: 20),
                   _buildSectionTitle('Administrativo & Finanzas'),
                   _buildGridAdmin(),

                   const SizedBox(height: 20),
                   _buildSectionTitle('Comunicaciones'),
                   _buildGridComunicaciones(),
                   
                   const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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
            '$greeting, Director',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Resumen de actividad escolar',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard(
          title: 'Estudiantes',
          value: _stats['totalEstudiantes'].toString(),
          icon: Icons.people,
          color: Colors.blue,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          title: 'Profesores',
          value: _stats['totalProfesores'].toString(),
          icon: Icons.school,
          color: Colors.orange,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          title: 'Ingresos Hoy',
          value: 'Bs ${_stats['ingresosHoy']}',
          icon: Icons.monetization_on,
          color: Colors.green,
        )),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0
          ),
        ),
      ),
    );
  }

  Widget _buildGridAcademia() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5, // Wider buttons
      children: const [
         _DashboardButton(icon: Icons.book, label: 'Cursos', route: '/dashboard-director/cursos'),
         _DashboardButton(icon: Icons.subject, label: 'Materias', route: '/dashboard-director/materias'),
         _DashboardButton(icon: Icons.schedule, label: 'Horarios', route: '/dashboard-director/horarios'),
         _DashboardButton(icon: Icons.assignment_ind, label: 'Asignaciones', route: '/dashboard-director/asignaciones'),
         _DashboardButton(icon: Icons.how_to_reg, label: 'Inscripciones', route: '/dashboard-director/inscripciones'),
         _DashboardButton(icon: Icons.grade, label: 'Notas', route: '/dashboard-director/notas'),
      ],
    );
  }

  Widget _buildGridComunidad() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: const [
         _DashboardButton(icon: Icons.school, label: 'Profesores', route: '/dashboard-director/profesores'),
         _DashboardButton(icon: Icons.people_alt, label: 'Estudiantes', route: '/dashboard-director/estudiantes'),
         _DashboardButton(icon: Icons.manage_accounts, label: 'Usuarios Sistema', route: '/dashboard-director/usuarios'),
         _DashboardButton(icon: Icons.event, label: 'Eventos', route: '/dashboard-director/eventos'),
      ],
    );
  }

  Widget _buildGridAdmin() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: const [
         _DashboardButton(icon: Icons.payment, label: 'Pagos', route: '/dashboard-director/pagos'),
         _DashboardButton(icon: Icons.account_balance_wallet, label: 'Tipo Pensión', route: '/dashboard-director/tipo-pension'),
         _DashboardButton(icon: Icons.calendar_today, label: 'Gestiones', route: '/dashboard-director/gestiones'),
         _DashboardButton(icon: Icons.settings, label: 'Configuración', route: '/dashboard-director/configuracion'),
      ],
    );
  }

  Widget _buildGridComunicaciones() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: const [
         _DashboardButton(icon: Icons.announcement, label: 'Gral. Comunicados', route: '/dashboard-director/comunicados-generales'),
         _DashboardButton(icon: Icons.message, label: 'Por Curso', route: '/dashboard-director/comunicados-curso'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             Icon(icon, size: 30, color: color),
             const SizedBox(height: 8),
             Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
             Text(title, style: const TextStyle(fontSize: 14)),
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