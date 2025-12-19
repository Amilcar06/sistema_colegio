import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';
import 'package:go_router/go_router.dart';
import '../models/asignacion_docente_response.dart';

class CursosAsignadosPage extends StatefulWidget {
  const CursosAsignadosPage({super.key});

  @override
  State<CursosAsignadosPage> createState() => _CursosAsignadosPageState();
}

class _CursosAsignadosPageState extends State<CursosAsignadosPage> {
  final ProfesorService _service = ProfesorService();
  bool _isLoading = true;
  List<AsignacionDocenteResponse> _asignaciones = [];
  
  // Filters
  final TextEditingController _searchCtrl = TextEditingController();
  String _nivelFilter = 'TODOS'; // TODOS, SECUNDARIA, PRIMARIA

  @override
  void initState() {
    super.initState();
    _cargarCursos();
    _searchCtrl.addListener(() { setState(() {}); });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCursos() async {
    try {
      final datos = await _service.getMisCursos();
      setState(() {
        _asignaciones = datos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AsignacionDocenteResponse> _getFilteredList() {
    return _asignaciones.where((item) {
      final matchesSearch = item.nombreMateria.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
                            item.nombreCurso.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      
      bool matchesNivel = true;
      if (_nivelFilter == 'SECUNDARIA') {
        matchesNivel = item.nombreCurso.toLowerCase().contains('sec');
      } else if (_nivelFilter == 'PRIMARIA') {
        matchesNivel = item.nombreCurso.toLowerCase().contains('prim');
      }

      return matchesSearch && matchesNivel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredById = _getFilteredList();

    return MainScaffold(
      title: 'Mis Cursos Asignados',
      child: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar materia o curso...',
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Filtrar por: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Todos', 'TODOS'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Secundaria', 'SECUNDARIA'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Primaria', 'PRIMARIA'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredById.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('No se encontraron cursos', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredById.length,
                      itemBuilder: (context, index) {
                        return _buildCursoCard(filteredById[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _nivelFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _nivelFilter = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCursoCard(AsignacionDocenteResponse item) {
    // Generate a color based on subject name char code sum to be consistent but different
    final colorSeed = item.nombreMateria.codeUnits.fold(0, (p, c) => p + c);
    final cardColor = Colors.accents[colorSeed % Colors.accents.length].shade100;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
         // Optional: Make card clickable to go to notes directly or detail
        child: Column(
          children: [
            // Header with Color
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: cardColor, // Or primaryColor
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.black87),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nombreMateria,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.nombreCurso,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      if (item.estado)
                        const Chip(
                          label: Text('Activo', style: TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.grade_outlined),
                          label: const Text('Notas'),
                          onPressed: () => context.push('/dashboard-profesor/notas/${item.idAsignacion}'),
                          style: TextButton.styleFrom(foregroundColor: Colors.blue.shade800),
                        ),
                      ),
                      Container(width: 1, height: 24, color: Colors.grey.shade300),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.people_outline),
                          label: const Text('Lista'),
                          onPressed: () {
                             // Route defined as /dashboard-profesor/estudiantes/:id   (Where ID is actually AsignacionID mostly used, but let's check router)
                             // Check router: /dashboard-profesor/estudiantes/:id -> uses DashboardProfesorInscritosPage(idAsignacion: id)
                             context.push('/dashboard-profesor/estudiantes/${item.idAsignacion}');
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.teal.shade700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
