import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/api_config.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/main_scaffold.dart';

class DashboardSecretaria extends StatefulWidget {
  const DashboardSecretaria({super.key});

  @override
  State<DashboardSecretaria> createState() => _DashboardSecretariaState();
}

class _DashboardSecretariaState extends State<DashboardSecretaria> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic>? _resumenDia;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarResumenDia();
  }

  Future<void> _cargarResumenDia() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/reportes/cierre-diario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _resumenDia = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        // Si hay error (ej. usuario nuevo sin movimientos), mostramos ceros o mensaje suave
        setState(() {
          _error = 'No se pudo cargar el resumen';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Valores por defecto si falla la carga o está cargando
    final recaudado = _resumenDia != null ? '${_resumenDia!['totalDia']}' : '...';
    final transacciones = _resumenDia != null ? '${_resumenDia!['transacciones']}' : '...';
    final fecha = _resumenDia != null 
        ? DateFormat('EEEE d MMMM', 'es').format(DateTime.parse(_resumenDia!['fecha']))
        : DateFormat('EEEE d MMMM', 'es').format(DateTime.now());

    return MainScaffold(
      title: 'Panel de Control',
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Hola, Secretaria',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    fecha.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // TARJETAS DE RESUMEN
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Recaudado Hoy',
                          value: 'Bs $recaudado',
                          icon: Icons.attach_money,
                          color: Colors.green,
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Transacciones',
                          value: transacciones,
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Accesos Rápidos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _ActionCard(
                  title: 'Nueva Inscripción',
                  icon: Icons.person_add,
                  color: Colors.orange,
                  onTap: () => context.go('/dashboard-secretaria/inscripciones/nueva'),
                ),
                _ActionCard(
                  title: 'Cobrar Mensualidad',
                  icon: Icons.payment,
                  color: Colors.purple,
                  // Redirigimos a Kardex/Buscador que es el flujo natural para cobrar
                  onTap: () => context.go('/dashboard-secretaria/kardex'),
                ),
                _ActionCard(
                  title: 'Historial Transacciones',
                  icon: Icons.history,
                  color: Colors.teal,
                  onTap: () => context.go('/dashboard-secretaria/transacciones'),
                ),
                _ActionCard(
                  title: 'Cierre de Caja',
                  icon: Icons.point_of_sale,
                  color: Colors.redAccent,
                  onTap: () => context.go('/dashboard-secretaria/cierre-caja'),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            isLoading
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
