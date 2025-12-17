import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../director/controller/usuarios_controller.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Cargar perfil al entrar si no está cargado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuarioController>().cargarPerfilAutenticado();
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Para mobile usamos File
      final file = File(image.path);
      final success = await context.read<UsuarioController>().subirFotoPerfil(file);
      if (success) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto actualizada')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsuarioController>();
    final user = controller.usuarioAutenticado;

    if (controller.cargando && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: const Center(child: Text('No se pudo cargar el perfil')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                   CircleAvatar(
                    radius: 60,
                    backgroundImage: (user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty)
                        ? NetworkImage(user.fotoPerfil!)
                        : null,
                    child: (user.fotoPerfil == null || user.fotoPerfil!.isEmpty)
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
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${user.nombres} ${user.apellidoPaterno} ${user.apellidoMaterno ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user.correo, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Chip(label: Text(user.rol.nombre)),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Correo Electrónico'),
              subtitle: Text(user.correo),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Estado'),
              subtitle: Text(user.estado ? 'Activo' : 'Inactivo'),
              trailing: user.estado 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
