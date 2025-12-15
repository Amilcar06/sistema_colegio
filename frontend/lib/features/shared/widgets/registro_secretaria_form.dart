import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../director/controller/usuarios_controller.dart';
import '../../director/models/usuario_sin_rol_request.dart';

class RegistroSecretariaForm extends StatefulWidget {
  const RegistroSecretariaForm({super.key});

  @override
  State<RegistroSecretariaForm> createState() => _RegistroSecretariaFormState();
}

class _RegistroSecretariaFormState extends State<RegistroSecretariaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombres = TextEditingController();
  final _apellidoPaterno = TextEditingController();
  final _apellidoMaterno = TextEditingController();
  final _ci = TextEditingController(); // Added CI
  final _correo = TextEditingController();
  final _password = TextEditingController();

  File? _fotoSeleccionada;
  String? _fotoPerfilUrl;
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    final controller = context.read<UsuarioController>();
    final usuario = controller.usuarioSeleccionado;
    if (usuario != null) {
      _esEdicion = true;
      _nombres.text = usuario.nombres;
      _apellidoPaterno.text = usuario.apellidoPaterno;
      _apellidoMaterno.text = usuario.apellidoMaterno ?? '';
      _ci.text = usuario.ci; // Added CI
      _correo.text = usuario.correo;
      _fotoPerfilUrl = usuario.fotoPerfilUrl;
      // No se llena el password por seguridad
    }
  }

  @override
  void dispose() {
    _nombres.dispose();
    _apellidoPaterno.dispose();
    _apellidoMaterno.dispose();
    _ci.dispose(); // Added CI
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _fotoSeleccionada = File(pickedFile.path);
        _fotoPerfilUrl = pickedFile.path;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dto = UsuarioSinRolRequestDTO(
      nombres: _nombres.text.trim(),
      apellidoPaterno: _apellidoPaterno.text.trim(),
      apellidoMaterno: _apellidoMaterno.text.trim(),
      ci: _ci.text.trim(), // Added CI
      correo: _correo.text.trim(),
      password: _password.text.trim().isEmpty ? '' : _password.text.trim(),
      fotoPerfilUrl: _fotoPerfilUrl,
    );

    final controller = context.read<UsuarioController>();

    if (_esEdicion) {
      await controller.actualizarUsuarioSeleccionadoSinRol(dto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados')),
      );
    } else {
      await controller.registrarSecretaria(dto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Secretaria registrada')),
      );
    }
    _formKey.currentState!.reset();
    controller.limpiarSeleccion();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Secretaria' : 'Registrar Secretaria')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombres,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _apellidoPaterno,
                decoration: const InputDecoration(labelText: 'Apellido paterno'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _apellidoMaterno,
                decoration: const InputDecoration(labelText: 'Apellido materno (opcional)'),
              ),
              TextFormField(
                controller: _ci,
                decoration: const InputDecoration(labelText: 'Carnet de Identidad'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _correo,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obligatorio';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  return regex.hasMatch(v) ? null : 'Correo inválido';
                },
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) => _esEdicion ? null : (v == null || v.isEmpty ? 'Campo obligatorio' : null),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _seleccionarFoto,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar Foto de Perfil'),
              ),
              if (_fotoSeleccionada != null)
                Image.file(_fotoSeleccionada!, height: 100),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_esEdicion ? 'Guardar Cambios' : 'Registrar Secretaria'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
