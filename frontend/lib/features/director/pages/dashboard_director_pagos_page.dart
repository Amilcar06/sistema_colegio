import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/api_config.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/reporte_service.dart';

class DashboardDirectorPagosPage extends StatefulWidget {
  const DashboardDirectorPagosPage({super.key});

  @override
  State<DashboardDirectorPagosPage> createState() =>
      _DashboardDirectorPagosPageState();
}

class _DashboardDirectorPagosPageState extends State<DashboardDirectorPagosPage>
    with SingleTickerProviderStateMixin {
  final ReporteService _reporteService = ReporteService();
  late TabController _tabController;

  bool _isLoadingReporte = false;
  Map<String, dynamic>? _dataIngresos;
  List<dynamic> _listaMorosos = [];
  bool _isLoadingMorosos = false;

  int _selectedYear = 2025;
  int _selectedMonth = 1; // Enero

  List<dynamic> _listaTransacciones = [];
  bool _isLoadingTransacciones = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarReporteIngresos();
    _cargarMorosos();
    _cargarTransacciones();
  }

  Future<void> _cargarTransacciones() async {
     if (_isLoadingTransacciones) return;
    setState(() => _isLoadingTransacciones = true);
    try {
      final data = await _reporteService.getUltimasTransacciones();
      setState(() {
        _listaTransacciones = data;
        _isLoadingTransacciones = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTransacciones = false);
        // Error silencioso o snackbar opcional
      }
    }
  }

  Future<void> _cargarReporteIngresos() async {
    if (_isLoadingReporte) return;
    setState(() => _isLoadingReporte = true);
    try {
      final data = await _reporteService.getReporteIngresos(_selectedYear, _selectedMonth);
      setState(() {
        _dataIngresos = data;
        _isLoadingReporte = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReporte = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _cargarMorosos() async {
     if (_isLoadingMorosos) return;
    setState(() => _isLoadingMorosos = true);
    try {
      final data = await _reporteService.getListaMorosos();
      setState(() {
        _listaMorosos = data;
        _isLoadingMorosos = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMorosos = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[900],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue[900],
              tabs: const [
                Tab(icon: Icon(Icons.receipt_long), text: "Transacciones"),
                Tab(icon: Icon(Icons.bar_chart), text: "Reporte Económico"),
                Tab(icon: Icon(Icons.warning_amber), text: "Control de Mora"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabTransacciones(),
                _buildTabReporte(),
                _buildTabMorosos(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabTransacciones() {
    if (_isLoadingTransacciones) return const Center(child: CircularProgressIndicator());
    if (_listaTransacciones.isEmpty) return const Center(child: Text("No hay transacciones recientes."));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Fecha")),
            DataColumn(label: Text("Recibo")),
            DataColumn(label: Text("Estudiante")),
            DataColumn(label: Text("Concepto")),
            DataColumn(label: Text("Monto (BOB)")),
             DataColumn(label: Text("Metodo")),
          ],
          rows: _listaTransacciones.map((t) {
            return DataRow(cells: [
              DataCell(Text(t['fecha']?.toString().split('T')[0] ?? '')),
              DataCell(Text(t['recibo'] ?? 'S/N')),
              DataCell(Text(t['estudiante'] ?? '')),
              DataCell(Text(t['concepto'] ?? '')),
              DataCell(Text(t['monto']?.toString() ?? '')),
               DataCell(Text(t['metodo']?.toString() ?? '')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabReporte() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: _selectedYear,
                items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
                onChanged: (val) {
                  setState(() => _selectedYear = val!);
                  _cargarReporteIngresos();
                },
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: _selectedMonth,
                items: List.generate(12, (index) => index + 1).map((m) {
                  return DropdownMenuItem(value: m, child: Text(_getMonthName(m)));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedMonth = val!);
                  _cargarReporteIngresos();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingReporte)
            const CircularProgressIndicator()
          else if (_dataIngresos != null)
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Total Ingresos: ${_dataIngresos!['totalMes']} BOB",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildChart()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getMonthName(int m) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[m - 1];
  }

  Widget _buildChart() {
    final List<dynamic> diarios = _dataIngresos!['ingresosDiarios'];
    // Filtrar y mapear datos para el gráfico
    // Vamos a asumir un punto por día. Si no hay dato, es 0.
    
    List<FlSpot> spots = [];
    int maxDay = 31; // Simplificación

    for (int i = 1; i <= maxDay; i++) {
       // Buscar si hay ingreso este día
       // fecha viene como YYYY-MM-DD
       // Parsear fecha simple
       double valor = 0;
       
       // Buscar en la lista
       for(var item in diarios) {
          DateTime date = DateTime.parse(item['fecha']);
          if(date.day == i) {
             valor = (item['total'] as num).toDouble();
             break;
          }
       }
       spots.add(FlSpot(i.toDouble(), valor));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
        minX: 1,
        maxX: 31,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTabMorosos() {
    if (_isLoadingMorosos) return const Center(child: CircularProgressIndicator());
    if (_listaMorosos.isEmpty) return const Center(child: Text("No hay estudiantes morosos."));

    return ListView.builder(
      itemCount: _listaMorosos.length,
      itemBuilder: (context, index) {
        final item = _listaMorosos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(item['nombreEstudiante'] ?? 'Desconocido'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['concepto']} - Vence: ${item['fechaVencimiento']}"),
                Text("Deuda: ${item['saldoPendiente']} BOB", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Generar PDF Recordatorio (Próximamente)")));
              },
            ),
          ),
        );
      },
    );
  }
}
