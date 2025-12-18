import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../director/controller/usuarios_controller.dart';
import '../../director/models/usuario_request.dart';
import '../../director/models/actualizar_password.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers
  final TextEditingController _nombresCtrl = TextEditingController();
  final TextEditingController _paternoCtrl = TextEditingController();
  final TextEditingController _maternoCtrl = TextEditingController();
  final TextEditingController _ciCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuarioController>().cargarPerfilAutenticado();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<UsuarioController>().usuarioAutenticado;
    if (user != null && !_initialized) {
      _nombresCtrl.text = user.nombres;
      _paternoCtrl.text = user.apellidoPaterno;
      _maternoCtrl.text = user.apellidoMaterno ?? '';
      _ciCtrl.text = user.ci;
      _correoCtrl.text = user.correo;
      _initialized = true;
    }
  }

  Future<void> _actualizarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<UsuarioController>();
    final user = controller.usuarioAutenticado;
    if (user == null) return;

    final dto = UsuarioRequestDTO(
      nombres: _nombresCtrl.text,
      apellidoPaterno: _paternoCtrl.text,
      apellidoMaterno: _maternoCtrl.text,
      ci: _ciCtrl.text,
      correo: _correoCtrl.text,
      password: '', // Importante: Backend debe manejar password vacia
      idRol: user.rol.idRol,
      fotoPerfilUrl: user.fotoPerfil,
      estado: user.estado,
      idUnidadEducativa: user.idUnidadEducativa,
      fechaNacimiento: user.fechaNacimiento,
    );

    final success = await controller.actualizarPerfilAutenticado(dto);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Error al actualizar')),
      );
    }
  }

  Future<void> _cambiarFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // Mobile uses File
    final file = File(image.path);
    if (mounted) {
      final success = await context.read<UsuarioController>().subirFotoPerfil(file);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto actualizada')));
      }
    }
  }

  void _mostrarDialogoPassword() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña Actual'),
              obscureText: true,
            ),
            TextField(
              controller: newPassCtrl,
              decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final dto = ActualizarPasswordDTO(
                  passwordActual: currentPassCtrl.text,
                  nuevaPassword: newPassCtrl.text
              );
              final success = await context.read<UsuarioController>().actualizarPassword(dto);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
              } else if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<UsuarioController>().errorMessage ?? 'Error')));
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsuarioController>();
    final user = controller.usuarioAutenticado;

    if (controller.cargando && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: (user?.fotoPerfil != null && user!.fotoPerfil!.isNotEmpty)
                          ? NetworkImage(user.fotoPerfil!)
                          : null,
                      child: (user?.fotoPerfil == null || user!.fotoPerfil!.isEmpty)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _cambiarFoto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              TextFormField(
                controller: _nombresCtrl,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _paternoCtrl,
                      decoration: const InputDecoration(labelText: 'Ap. Paterno'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _maternoCtrl,
                      decoration: const InputDecoration(labelText: 'Ap. Materno'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ciCtrl,
                decoration: const InputDecoration(labelText: 'Carnet Identidad'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _correoCtrl,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _actualizarPerfil,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Cambios'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _mostrarDialogoPassword,
                icon: const Icon(Icons.lock),
                label: const Text('Cambiar Contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
