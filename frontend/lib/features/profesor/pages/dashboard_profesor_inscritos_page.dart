import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import '../models/boletin_notas_model.dart';
import 'package:go_router/go_router.dart';

class DashboardProfesorInscritosPage extends StatefulWidget {
  final String idAsignacion;

  const DashboardProfesorInscritosPage({super.key, this.idAsignacion = ''});

  @override
  State<DashboardProfesorInscritosPage> createState() => _DashboardProfesorInscritosPageState();
}

class _DashboardProfesorInscritosPageState extends State<DashboardProfesorInscritosPage> {
  bool _isLoading = true;
  List<BoletinNotasModel> _estudiantes = [];
  String? _error;
  
  // Search
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarEstudiantes();
    });
    _searchCtrl.addListener(() { setState(() {}); });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarEstudiantes() async {
    if (widget.idAsignacion.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No se seleccionó ningún curso.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profesorService = ProfesorService();
      // Reuse getBoletinCurso with 'PRIMER' trimester default to get list
      final estudiantes = await profesorService.getBoletinCurso(
        int.parse(widget.idAsignacion),
        'PRIMER', 
      );

      setState(() {
        _estudiantes = estudiantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar estudiantes: $e';
        _isLoading = false;
      });
    }
  }

  List<BoletinNotasModel> _getFilteredList() {
    return _estudiantes.where((item) {
      return item.nombreEstudiante.toLowerCase().contains(_searchCtrl.text.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Listado de Estudiantes',
      child: _content(),
    );
  }

  Widget _content() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarEstudiantes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_estudiantes.isEmpty) {
      return const Center(child: Text('No hay estudiantes inscritos en este curso (o error en carga).'));
    }

    final filteredList = _getFilteredList();

    return Column(
      children: [
        // Search Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar estudiante...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        Expanded(
          child: filteredList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No se encontraron estudiantes', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final est = filteredList[index];
                    return _buildStudentCard(est, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(BoletinNotasModel est, int index) {
    // Alternating colors for avatars based on index or name
    final avatarColor = Colors.primaries[index % Colors.primaries.length].shade100;
    final textColor = Colors.primaries[index % Colors.primaries.length].shade900;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Text(
            est.nombreEstudiante.isNotEmpty ? est.nombreEstudiante[0].toUpperCase() : '?',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          est.nombreEstudiante,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('ID Estudiante: ${est.idEstudiante}'),
        trailing: IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
          tooltip: 'Ver Rendimiento',
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detalle de estudiante próximamente...')));
          },
        ),
      ),
    );
  }
}
