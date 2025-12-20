import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../director/services/comunicado_service.dart';
import '../services/estudiante_service.dart';
import '../services/pago_service.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../models/estudiante_response.dart';
import 'package:intl/intl.dart';

class DashboardEstudiante extends StatefulWidget {
  const DashboardEstudiante({super.key});

  @override
  State<DashboardEstudiante> createState() => _DashboardEstudianteState();
}

class _DashboardEstudianteState extends State<DashboardEstudiante> {
  final _estudianteService = EstudianteService();
  final _pagoService = PagoService();
  final _comunicadoService = ComunicadoService();

  bool _isLoading = true;
  EstudianteResponseDTO? _perfil;
  List<dynamic> _deudasPendientes = [];
  List<dynamic> _comunicadosRecientes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      // 1. Obtener Perfil
      final perfil = await _estudianteService.obtenerPerfil();
      _perfil = perfil;

      // 2. Obtener Deudas (para saber estado mes actual)
      // Nota: Asumimos que listarDeudas devuelve todo lo pendiente
      final deudas = await _pagoService.listarDeudas(perfil.idEstudiante);
      _deudasPendientes = deudas;

      // 3. Obtener Comunicados (Generales por ahora, idealmente filtrados por curso)
      // Usamos el servicio existente. Si no hay endpoint específico para "mis comunicados",
      // usamos el general.
      final comunicados = await _comunicadoService.listar();
      // Tomamos los 2 más recientes y los convertimos a JSON para el widget (o adaptamos el widget)
      _comunicadosRecientes = comunicados.take(2).map((c) => c.toJson()).toList();
      
    } catch (e) {
      // Si falla algo no bloqueamos todo el dashboard, pero registramos el error
      print('Error cargando dashboard estudiante: $e');
      _error = 'No se pudieron cargar algunos datos.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fecha actual formateada
    final fechaHoy = DateFormat('EEEE d ' 'de' ' MMMM', 'es').format(DateTime.now());

    return MainScaffold(
      title: 'Mi Portal',
      child: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // HEADING
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${_perfil?.nombres ?? 'Estudiante'}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      fechaHoy.toUpperCase(), // Capitalization trick
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // 1. TARJETA RESUMEN FINANCIERO
                        _buildFinanceCard(),
                        const SizedBox(height: 16),
                        
                        // 2. ACCESOS RAPIDOS (BOTONES)
                        Row(
                          children: [
                            Expanded(child: _QuickActionCard(
                              icon: Icons.assignment, 
                              label: 'Mis Notas', 
                              color: Colors.blue.shade100, 
                              iconColor: Colors.blue.shade800,
                              onTap: () => context.push('/dashboard-estudiante/notas'),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _QuickActionCard(
                              icon: Icons.schedule, 
                              label: 'Horario', 
                              color: Colors.orange.shade100, 
                              iconColor: Colors.orange.shade800,
                              onTap: () => context.push('/dashboard-estudiante/horarios'),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _QuickActionCard(
                              icon: Icons.payments, 
                              label: 'Pagos', 
                              color: Colors.green.shade100, 
                              iconColor: Colors.green.shade800,
                              onTap: () => context.push('/dashboard-estudiante/pagos'),
                            )),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 3. SECCION AVISOS
                        Row(
                          children: [
                            const Icon(Icons.campaign, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('Últimos Avisos', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        if (_comunicadosRecientes.isEmpty)
                           const Card(
                             child: Padding(
                               padding: EdgeInsets.all(16.0), 
                               child: Text('No hay avisos recientes.'),
                             )
                           )
                        else
                          ..._comunicadosRecientes.map((c) => _ComunicadoCard(comunicado: c)),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceCard() {
    final tieneDeudas = _deudasPendientes.isNotEmpty;
    // Lógica simple: Si tiene deudas, le avisamos. Si no, "Estás al día".
    // Podríamos filtrar solo deudas VENCIDAS si quisiéramos, pero por ahora "Pendientes" es suficiente alerta.

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: tieneDeudas ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: tieneDeudas ? Colors.red.shade100 : Colors.green.shade100),
              ),
              child: Icon(
                tieneDeudas ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: tieneDeudas ? Colors.red : Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieneDeudas ? 'Tienes pagos pendientes' : 'Estás al día',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tieneDeudas ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                   Text(
                    tieneDeudas 
                      ? 'Revisa tu estado de cuenta para evitar recargos.' 
                      : 'Gracias por tu puntualidad. No tienes deudas vencidas.',
                    style: TextStyle(
                      color: tieneDeudas ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (tieneDeudas)
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => context.push('/dashboard-estudiante/pagos'),
              )
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100, // Alto fijo para cuadrar
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ComunicadoCard extends StatelessWidget {
  final dynamic comunicado;

  const _ComunicadoCard({required this.comunicado});

  @override
  Widget build(BuildContext context) {
    // Safety check type
    final titulo = comunicado['titulo'] ?? 'Sin título';
    final contenido = comunicado['contenido'] ?? '';
    final fecha = comunicado['fechaPublicacion'] ?? ''; // YYYY-MM-DD

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(contenido, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(fecha, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
