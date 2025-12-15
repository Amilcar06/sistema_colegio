import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/shared/widgets/main_scaffold.dart';
import '../services/profesor_service.dart';

class RegistroNotasPage extends StatefulWidget {
  final String idAsignacion;

  const RegistroNotasPage({super.key, required this.idAsignacion});

  @override
  State<RegistroNotasPage> createState() => _RegistroNotasPageState();
}

class _RegistroNotasPageState extends State<RegistroNotasPage> {
  final ProfesorService _service = ProfesorService();
  bool _isLoading = true;
  Map<String, dynamic> _libreta = {};
  List<dynamic> _estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarLibreta();
  }

  Future<void> _cargarLibreta() async {
    try {
      final data = await _service.getLibreta(widget.idAsignacion);
      setState(() {
        _libreta = data;
        _estudiantes = data['estudiantes'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notas: $e')),
        );
      }
    }
  }

  Future<void> _guardarNota(
      int idEstudiante, String trimester, double? valor, int? idNota) async {
    // Si el valor es null, no hacemos nada de momento (o podríamos borrar)
    if (valor == null) return;

    // TODO: Validar rango 0-100

    try {
      if (idNota == null) {
        // Crear nota
        await _service.registrarNota({
          'idEstudiante': idEstudiante,
          'idAsignacion': int.parse(widget.idAsignacion),
          'valor': valor,
          'trimestre': trimester
        });
      } else {
        // Actualizar nota
        await _service.actualizarNota(idNota, {
          'valor': valor,
          'trimestre': trimester // Se requiere aunque no cambie
        });
      }
      
      // Recargar para obtener los nuevos IDs (especialmente si fue crear)
      _cargarLibreta();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: _isLoading ? 'Cargando...' : 'Notas: ${_libreta['materia']} - ${_libreta['curso']}',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Gestión: ${_libreta['gestion']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Estudiante')),
                        DataColumn(label: Text('1° Trimestre')),
                        DataColumn(label: Text('2° Trimestre')),
                        DataColumn(label: Text('3° Trimestre')),
                      ],
                      rows: _estudiantes.map<DataRow>((est) {
                        return DataRow(cells: [
                          DataCell(Text(est['nombreCompleto'])),
                          _buildNotaCell(est, 'PRIMER', 'notaPrimerTrimestre', 'idNotaPrimerTrimestre'),
                          _buildNotaCell(est, 'SEGUNDO', 'notaSegundoTrimestre', 'idNotaSegundoTrimestre'),
                          _buildNotaCell(est, 'TERCER', 'notaTercerTrimestre', 'idNotaTercerTrimestre'),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  DataCell _buildNotaCell(dynamic estudiante, String trimesterKey, String valorKey, String idKey) {
    final valor = estudiante[valorKey];
    final idNota = estudiante[idKey];
    final controller = TextEditingController(text: valor != null ? valor.toString() : '');

    return DataCell(
      SizedBox(
        width: 60,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '-',
          ),
          onSubmitted: (value) {
            final double? newValor = double.tryParse(value);
            if (newValor != null) {
              _guardarNota(estudiante['idEstudiante'], trimesterKey, newValor, idNota);
            }
          },
        ),
      ),
    );
  }
}
