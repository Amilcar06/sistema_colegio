/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidad_educatica_frontend/features/estudiante/models/estudiante_request.dart';
import '../../estudiante/controller/estudiante_controller.dart';
import '../../estudiante/models/estudiante_registro_completo.dart';

class RegistroEstudianteForm extends StatefulWidget {
  const RegistroEstudianteForm({super.key});

  @override
  State<RegistroEstudianteForm> createState() => _RegistroEstudianteFormState();
}

class _RegistroEstudianteFormState extends State<RegistroEstudianteForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombresController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ciController = TextEditingController();
  final _telefonoPadreController = TextEditingController();
  final _telefonoMadreController = TextEditingController();
  final _direccionController = TextEditingController();
  DateTime? _fechaNacimiento;

  bool _datosPrecargados = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final est = context.watch<EstudianteController>().estudianteSeleccionado;
    if (!_datosPrecargados && est != null) {
      _nombresController.text = est.nombres;
      _apellidoPaternoController.text = est.apellidoPaterno;
      _apellidoMaternoController.text = est.apellidoMaterno ?? '';
      _correoController.text = est.correo;
      _ciController.text = est.ci;
      _telefonoPadreController.text = est.telefonoPadre;
      _telefonoMadreController.text = est.telefonoMadre;
      _direccionController.text = est.direccion;
      _fechaNacimiento = est.fechaNacimiento;
      _datosPrecargados = true;
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _ciController.dispose();
    _telefonoPadreController.dispose();
    _telefonoMadreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final controller = context.read<EstudianteController>();
      final esEdicion = controller.estudianteSeleccionado != null;

      if (_fechaNacimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar la fecha de nacimiento')),
        );
        return;
      }

      final dto = EstudianteRegistroCompletoDTO(
        nombres: _nombresController.text.trim(),
        apellidoPaterno: _apellidoPaternoController.text.trim(),
        apellidoMaterno: _apellidoMaternoController.text.trim(),
        correo: _correoController.text.trim(),
        password: _passwordController.text.trim(),
        ci: _ciController.text.trim(),
        direccion: _direccionController.text.trim(),
        telefonoPadre: _telefonoPadreController.text.trim(),
        telefonoMadre: _telefonoMadreController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
      );

      final exito = esEdicion
          ? await controller.actualizar(dto)
          : await controller.registrar(dto);

      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(esEdicion ? 'Estudiante actualizado' : 'Estudiante registrado')),
        );
        _formKey.currentState!.reset();
        controller.cancelarEdicion();
        setState(() {}); // Limpia campos
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage ?? 'Ocurrió un error')),
        );
      }
    }
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2010),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = context.watch<EstudianteController>().estudianteSeleccionado != null;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nombresController,
              decoration: const InputDecoration(labelText: 'Nombres'),
              validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
            ),
            TextFormField(
              controller: _apellidoPaternoController,
              decoration: const InputDecoration(labelText: 'Apellido paterno'),
              validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
            ),
            TextFormField(
              controller: _apellidoMaternoController,
              decoration: const InputDecoration(labelText: 'Apellido materno'),
            ),
            TextFormField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obligatorio';
                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                return regex.hasMatch(v) ? null : 'Correo inválido';
              },
            ),
            if (!esEdicion)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
            TextFormField(
              controller: _ciController,
              decoration: const InputDecoration(labelText: 'CI'),
              validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
            ),
            TextFormField(
              controller: _telefonoPadreController,
              decoration: const InputDecoration(labelText: 'Teléfono del padre'),
              validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
            ),
            TextFormField(
              controller: _telefonoMadreController,
              decoration: const InputDecoration(labelText: 'Teléfono de la madre'),
              validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
            ),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Fecha de nacimiento: "),
                const SizedBox(width: 8),
                Text(_fechaNacimiento == null
                    ? 'No seleccionada'
                    : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _seleccionarFechaNacimiento,
                  child: const Text("Seleccionar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(esEdicion ? 'Actualizar Estudiante' : 'Registrar Estudiante'),
            ),
            if (esEdicion)
              TextButton(
                onPressed: () {
                  context.read<EstudianteController>().cancelarEdicion();
                  _formKey.currentState?.reset();
                  _nombresController.clear();
                  _apellidoPaternoController.clear();
                  _apellidoMaternoController.clear();
                  _correoController.clear();
                  _passwordController.clear();
                  _ciController.clear();
                  _telefonoPadreController.clear();
                  _telefonoMadreController.clear();
                  _direccionController.clear();
                  _fechaNacimiento = null;
                  setState(() {
                    _datosPrecargados = false;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Cancelar edición'),
              ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidad_educatica_frontend/features/estudiante/controller/estudiante_controller.dart';
import 'package:unidad_educatica_frontend/features/estudiante/models/estudiante_registro_completo.dart';

class RegistroEstudianteForm extends StatefulWidget {
  const RegistroEstudianteForm({super.key});

  @override
  State<RegistroEstudianteForm> createState() => _RegistroEstudianteFormState();
}

class _RegistroEstudianteFormState extends State<RegistroEstudianteForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombresController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ciController = TextEditingController();
  final _telefonoPadreController = TextEditingController();
  final _telefonoMadreController = TextEditingController();
  final _direccionController = TextEditingController();

  DateTime? _fechaNacimiento;
  bool _datosPrecargados = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final est = context.watch<EstudianteController>().estudianteSeleccionado;
    if (!_datosPrecargados && est != null) {
      _nombresController.text = est.nombres;
      _apellidoPaternoController.text = est.apellidoPaterno;
      _apellidoMaternoController.text = est.apellidoMaterno ?? '';
      _correoController.text = est.correo;
      _ciController.text = est.ci;
      _telefonoPadreController.text = est.telefonoPadre;
      _telefonoMadreController.text = est.telefonoMadre;
      _direccionController.text = est.direccion;
      _fechaNacimiento = est.fechaNacimiento;
      _datosPrecargados = true;
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _ciController.dispose();
    _telefonoPadreController.dispose();
    _telefonoMadreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2010),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar la fecha de nacimiento')),
      );
      return;
    }

    final controller = context.read<EstudianteController>();
    final esEdicion = controller.estudianteSeleccionado != null;

    final dto = EstudianteRegistroCompletoDTO(
      nombres: _nombresController.text.trim(),
      apellidoPaterno: _apellidoPaternoController.text.trim(),
      apellidoMaterno: _apellidoMaternoController.text.trim(),
      correo: _correoController.text.trim(),
      password: _passwordController.text.trim(),
      ci: _ciController.text.trim(),
      direccion: _direccionController.text.trim(),
      telefonoPadre: _telefonoPadreController.text.trim(),
      telefonoMadre: _telefonoMadreController.text.trim(),
      fechaNacimiento: _fechaNacimiento!,
    );

    final exito = esEdicion
        ? await controller.actualizar(dto)
        : await controller.registrar(dto);

    if (exito) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(esEdicion ? 'Estudiante actualizado' : 'Estudiante registrado')),
      );
      _formKey.currentState!.reset();
      controller.cancelarEdicion();
      setState(() {
        _datosPrecargados = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Ocurrió un error')),
      );
    }
  }

  void _cancelarEdicion() {
    final controller = context.read<EstudianteController>();
    controller.cancelarEdicion();
    _formKey.currentState?.reset();
    _nombresController.clear();
    _apellidoPaternoController.clear();
    _apellidoMaternoController.clear();
    _correoController.clear();
    _passwordController.clear();
    _ciController.clear();
    _telefonoPadreController.clear();
    _telefonoMadreController.clear();
    _direccionController.clear();
    _fechaNacimiento = null;
    setState(() {
      _datosPrecargados = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = context.watch<EstudianteController>().estudianteSeleccionado != null;

    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Estudiante' : 'Registrar Estudiante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _apellidoPaternoController,
                decoration: const InputDecoration(labelText: 'Apellido paterno'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _apellidoMaternoController,
                decoration: const InputDecoration(labelText: 'Apellido materno'),
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obligatorio';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  return regex.hasMatch(v) ? null : 'Correo inválido';
                },
              ),
              if (!esEdicion)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                ),
              TextFormField(
                controller: _ciController,
                decoration: const InputDecoration(labelText: 'CI'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _telefonoPadreController,
                decoration: const InputDecoration(labelText: 'Teléfono del padre'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _telefonoMadreController,
                decoration: const InputDecoration(labelText: 'Teléfono de la madre'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Fecha de nacimiento: "),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _fechaNacimiento == null
                          ? 'No seleccionada'
                          : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: _seleccionarFechaNacimiento,
                    child: const Text("Seleccionar"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(esEdicion ? 'Guardar Cambios' : 'Registrar Estudiante'),
              ),
              if (esEdicion)
                TextButton(
                  onPressed: _cancelarEdicion,
                  child: const Text('Cancelar edición'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
