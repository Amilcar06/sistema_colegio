import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../controller/curso_controller.dart';
import '../models/grado.dart';

class DashboardDirectorCursosPage extends StatelessWidget {
  const DashboardDirectorCursosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CursoController(),
      child: const _CursosView(),
    );
  }
}

class _CursosView extends StatelessWidget {
  const _CursosView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CursoController>();

    return MainScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gestión de Cursos',
                    style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  onPressed: () => _abrirDialogoCrear(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Curso'),
                ),
              ],
            ),
          ),
          if (controller.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (controller.errorMessage != null)
            Expanded(
                child: Center(
                    child: Text('Error: ${controller.errorMessage}',
                        style: const TextStyle(color: Colors.red))))
          else
            Expanded(
              child: ListView.builder(
                itemCount: controller.cursos.length,
                itemBuilder: (context, index) {
                  final curso = controller.cursos[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(curso.paralelo),
                        backgroundColor: _getColorForTurno(curso.turno),
                        foregroundColor: Colors.white,
                      ),
                      title: Text(curso.nombreGrado),
                      subtitle: Text('${curso.nivel} - ${curso.turno}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => controller.eliminarCurso(curso.idCurso),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorForTurno(String turno) {
    switch (turno.toUpperCase()) {
      case 'MANANA':
        return Colors.orange;
      case 'TARDE':
        return Colors.blue;
      case 'NOCHE':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _abrirDialogoCrear(BuildContext parentContext) {
    // Usamos parentContext.read porque el dialog se construye en otro ambito, 
    // pero queremos acceder al controlador existente.
    // Sin embargo, showDialog crea una nueva ruta. Lo mejor es pasar el controller o usar consumer dentro.
    // O mejor aun, instanciar un widget Stateful que use el provider.
    
    showDialog(
      context: parentContext,
      builder: (_) => ChangeNotifierProvider.value(
        value: parentContext.read<CursoController>(),
        child: const _CrearCursoDialog(),
      ),
    );
  }
}

class _CrearCursoDialog extends StatefulWidget {
  const _CrearCursoDialog();

  @override
  State<_CrearCursoDialog> createState() => _CrearCursoDialogState();
}

class _CrearCursoDialogState extends State<_CrearCursoDialog> {
  final _formKey = GlobalKey<FormState>();
  
  Grado? _gradoSeleccionado;
  String? _paralelo;
  String _turno = 'MAÑANA';

  final List<String> _paralelos = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _turnos = ['MAÑANA', 'TARDE', 'NOCHE'];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CursoController>();

    return AlertDialog(
      title: const Text('Registrar Nuevo Curso'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown Grados
              DropdownButtonFormField<Grado>(
                decoration: const InputDecoration(labelText: 'Grado'),
                value: _gradoSeleccionado,
                items: controller.grados.map((grado) {
                  return DropdownMenuItem(
                    value: grado,
                    child: Text('${grado.nombre} (${grado.nivel})'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _gradoSeleccionado = value),
                validator: (value) => value == null ? 'Seleccione un grado' : null,
              ),

              const SizedBox(height: 16),

              // Dropdown Paralelo
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Paralelo'),
                value: _paralelo,
                items: _paralelos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (value) => setState(() => _paralelo = value),
                validator: (value) => value == null ? 'Seleccione un paralelo' : null,
              ),

              const SizedBox(height: 16),
              
              // Dropdown Turno
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Turno'),
                value: _turno,
                items: _turnos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (value) => setState(() => _turno = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Convertir turno a formato Enum si es necesario, o enviar string directo si el backend lo soporta
              // El backend espera MANANA, TARDE, NOCHE sin ñ creo.
              // Revisemos el DTO Enum Java: TipoTurno { MANANA, TARDE, NOCHE }
              String turnoEnvio = _turno == 'MAÑANA' ? 'MANANA' : _turno;
              
              final exito = await controller.crearCurso(
                _gradoSeleccionado!.idGrado,
                _paralelo!,
                turnoEnvio,
              );
              
              if (exito && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Curso creado exitosamente')),
                );
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
