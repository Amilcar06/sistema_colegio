import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/estudiante_service.dart';
import '../services/nota_service.dart';
import '../models/estudiante_response.dart';
import '../../../core/utils/pdf_util.dart';

class DashboardEstudianteNotasPage extends StatefulWidget {
  const DashboardEstudianteNotasPage({super.key});

  @override
  State<DashboardEstudianteNotasPage> createState() => _DashboardEstudianteNotasPageState();
}

class _DashboardEstudianteNotasPageState extends State<DashboardEstudianteNotasPage> {
  final _estudianteService = EstudianteService();
  final _notaService = NotaService();

  bool _isLoading = true;
  EstudianteResponseDTO? _estudiante;
  
  // Gestiones
  List<Map<String, dynamic>> _gestiones = [];
  int? _selectedGestionId;

  // Data del boletín
  Map<String, dynamic>? _boletinData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final est = await _estudianteService.obtenerPerfil();
      _estudiante = est;

      // Cargar gestiones
      final gestiones = await _estudianteService.listarGestiones(est.idEstudiante);
      _gestiones = gestiones;

      // Seleccionar por defecto la gestión activa (estado = true) o la última el año más reciente
      if (_gestiones.isNotEmpty) {
        final activa = _gestiones.firstWhere(
          (g) => g['estado'] == true,
          orElse: () => _gestiones.last, // Fallback a cualquiera
        );
        _selectedGestionId = activa['idGestion'];
      }

      await _cargarBoletin();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarBoletin() async {
    if (_estudiante == null || _selectedGestionId == null) return;
    
    setState(() => _isLoading = true);
    try {
      final data = await _notaService.obtenerBoletin(
        _estudiante!.idEstudiante,
        idGestion: _selectedGestionId,
      );
      _boletinData = data;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGestionChanged(int? newValue) async {
    if (newValue == null) return;
    setState(() {
      _selectedGestionId = newValue;
    });
    await _cargarBoletin();
  }

  Future<void> _descargarBoletin() async {
    if (_estudiante == null) return;
    try {
      final bytes = await _estudianteService.descargarBoletin(
        _estudiante!.idEstudiante,
        idGestion: _selectedGestionId
      );
      PdfUtil.descargarPdfWeb(bytes, "Boletin_${_estudiante!.ci}.pdf");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boletín descargado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar boletín: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mis Calificaciones',
      actions: [
        if (_estudiante != null && _boletinData != null)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _descargarBoletin,
            tooltip: 'Descargar Boletín Actual',
          ),
      ],
      child: _isLoading && _estudiante == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_estudiante == null) return const Center(child: Text('No se encontró información.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con datos y selector
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 40, color: Colors.blue),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_estudiante?.nombres} ${_estudiante?.apellidoPaterno}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('CI: ${_estudiante?.ci}'),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Gestión Académica:", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: _selectedGestionId,
                        hint: const Text("Seleccionar gestión"),
                        items: _gestiones.map((g) {
                          return DropdownMenuItem<int>(
                            value: g['idGestion'],
                            child: Text(g['anio'].toString()),
                          );
                        }).toList(),
                        onChanged: _onGestionChanged,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
             const Center(child: CircularProgressIndicator())
          else if (_boletinData == null)
             const Center(child: Text("No hay datos para esta gestión"))
          else 
             _buildGradesTable(),
        ],
      ),
    );
  }

  Widget _buildGradesTable() {
    // Procesar notas para agrupar por materia
    // Entructura esperada de _boletinData['notas'] -> List of { materia, trimestre, valor }
    final List<dynamic> notasRaw = _boletinData!['notas'] ?? [];
    
    // Map<Materia, Map<Trimestre, Nota>>
    final Map<String, Map<String, double>> tableData = {};

    for (var n in notasRaw) {
      final materia = n['materia'] ?? 'Desconocida';
      final trimestre = n['trimestre'] ?? 'UNKNOWN';
      final valor = (n['valor'] as num?)?.toDouble() ?? 0.0;

      tableData.putIfAbsent(materia, () => {});
      tableData[materia]![trimestre] = valor;
    }

    if (tableData.isEmpty) {
      return const Center(child: Text("No se encontraron notas registradas."));
    }

    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Materia', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('1° Trimestre', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('2° Trimestre', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('3° Trimestre', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: tableData.entries.map((entry) {
            final materia = entry.key;
            final notas = entry.value;
            final n1 = notas['PRIMER'] ?? 0.0;
            final n2 = notas['SEGUNDO'] ?? 0.0;
            final n3 = notas['TERCER'] ?? 0.0;

            return DataRow(cells: [
              DataCell(Text(materia)),
              DataCell(Text(n1.toStringAsFixed(1))),
              DataCell(Text(n2.toStringAsFixed(1))),
              DataCell(Text(n3.toStringAsFixed(1))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
