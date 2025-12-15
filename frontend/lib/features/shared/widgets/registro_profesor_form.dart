import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profesor/controller/profesor_controller.dart';
import '../../profesor/models/profesor_registro_completo.dart';

class RegistroProfesorForm extends StatefulWidget {
  const RegistroProfesorForm({super.key});

  @override
  State<RegistroProfesorForm> createState() => _RegistroProfesorFormState();
}

class _RegistroProfesorFormState extends State<RegistroProfesorForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombresController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ciController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _profesionController = TextEditingController();

  bool _datosPrecargados = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prof = context.watch<ProfesorController>().profesorSeleccionado;
    if (!_datosPrecargados && prof != null) {
      _nombresController.text = prof.nombres;
      _apellidoPaternoController.text = prof.apellidoPaterno;
      _apellidoMaternoController.text = prof.apellidoMaterno ?? '';
      _correoController.text = prof.correo;
      _ciController.text = prof.ci;
      _telefonoController.text = prof.telefono;
      _profesionController.text = prof.profesion ?? '';
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
    _telefonoController.dispose();
    _profesionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ProfesorController>();
    final esEdicion = controller.profesorSeleccionado != null;

    final dto = ProfesorRegistroCompletoDTO(
      nombres: _nombresController.text.trim(),
      apellidoPaterno: _apellidoPaternoController.text.trim(),
      apellidoMaterno: _apellidoMaternoController.text.trim(),
      correo: _correoController.text.trim(),
      password: _passwordController.text.trim(),
      ci: _ciController.text.trim(),
      telefono: _telefonoController.text.trim(),
      profesion: _profesionController.text.trim(),
    );

    final exito = esEdicion
        ? await controller.actualizar(dto)
        : await controller.registrar(dto);

    if (exito) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(esEdicion ? 'Profesor actualizado' : 'Profesor registrado')),
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
    final controller = context.read<ProfesorController>();
    controller.cancelarEdicion();
    _formKey.currentState?.reset();
    _nombresController.clear();
    _apellidoPaternoController.clear();
    _apellidoMaternoController.clear();
    _correoController.clear();
    _passwordController.clear();
    _ciController.clear();
    _telefonoController.clear();
    _profesionController.clear();
    _datosPrecargados = false;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = context.watch<ProfesorController>().profesorSeleccionado != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Profesor' : 'Registrar Profesor'),
      ),
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
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ciController,
                decoration: const InputDecoration(labelText: 'CI'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _profesionController,
                decoration: const InputDecoration(labelText: 'Profesión (opcional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(esEdicion ? 'Guardar Cambios' : 'Registrar Profesor'),
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
