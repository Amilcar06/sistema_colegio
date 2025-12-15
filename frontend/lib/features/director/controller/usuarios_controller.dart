import 'package:flutter/material.dart';
import '../models/usuario_request.dart';
import '../models/usuario_response.dart';
import '../models/actualizar_password.dart';
import '../models/usuario_sin_rol_request.dart';
import '../services/usuario_service.dart';

class UsuarioController with ChangeNotifier {
  final UsuarioService _service = UsuarioService();

  List<UsuarioResponseDTO> usuarios = [];
  bool cargando = false;
  String? errorMessage;

  UsuarioResponseDTO? usuarioSeleccionado;
  UsuarioResponseDTO? usuarioAutenticado;

  /// Cargar lista de usuarios
  Future<void> cargarUsuarios() async {
    cargando = true;
    errorMessage = null;
    notifyListeners();

    try {
      usuarios = await _service.listarUsuariosSecretarias();
    } catch (e) {
      errorMessage = 'Error al cargar usuarios: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Registrar un director (sin rol explícito)
  Future<bool> registrarDirector(UsuarioSinRolRequestDTO dto) async {
    errorMessage = null;
    try {
      await _service.registrarDirector(dto);
      await cargarUsuarios();
      return true;
    } catch (e) {
      errorMessage = 'Error al registrar director: $e';
      notifyListeners();
      return false;
    }
  }

  /// Registrar una secretaria (sin rol explícito)
  Future<bool> registrarSecretaria(UsuarioSinRolRequestDTO dto) async {
    errorMessage = null;
    try {
      await _service.registrarSecretaria(dto);
      await cargarUsuarios();
      return true;
    } catch (e) {
      errorMessage = 'Error al registrar secretaria: $e';
      notifyListeners();
      return false;
    }
  }

  /// Eliminar usuario por ID
  Future<void> eliminarUsuario(int idUsuario) async {
    try {
      await _service.eliminarUsuario(idUsuario);
      usuarios.removeWhere((u) => u.idUsuario == idUsuario);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al eliminar usuario: $e';
      notifyListeners();
    }
  }

  /// Filtrar usuarios por nombre de rol (ej: 'DIRECTOR')
  List<UsuarioResponseDTO> usuariosPorRol(String rolNombre) {
    return usuarios.where((u) => u.rol.nombre.toUpperCase() == rolNombre.toUpperCase()).toList();
  }

  /// Seleccionar usuario para edición
  void seleccionarParaEdicion(UsuarioResponseDTO usuario) {
    usuarioSeleccionado = usuario;
    notifyListeners();
  }

  /// Limpiar usuario seleccionado
  void limpiarSeleccion() {
    usuarioSeleccionado = null;
    notifyListeners();
  }

  /// Actualizar usuario seleccionado
  Future<void> actualizarUsuarioSeleccionado(UsuarioRequestDTO dto) async {
    if (usuarioSeleccionado == null) return;

    try {
      final actualizado = await _service.actualizarUsuario(
        usuarioSeleccionado!.idUsuario,
        dto,
      );

      final index = usuarios.indexWhere((u) => u.idUsuario == actualizado.idUsuario);
      if (index != -1) {
        usuarios[index] = actualizado;
      }

      usuarioSeleccionado = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al actualizar usuario: $e';
      notifyListeners();
    }
  }

  Future<void> actualizarUsuarioSeleccionadoSinRol(UsuarioSinRolRequestDTO dto) async {
    if (usuarioSeleccionado == null) return;

    // Convertimos dto sin rol a dto con rol manteniendo el idRol original
    final dtoCompleto = UsuarioRequestDTO(
      nombres: dto.nombres,
      apellidoPaterno: dto.apellidoPaterno,
      apellidoMaterno: dto.apellidoMaterno,
      correo: dto.correo,
      password: dto.password,
      fotoPerfilUrl: dto.fotoPerfilUrl,
      estado: dto.estado,
      idRol: usuarioSeleccionado!.rol.idRol,
    );

    await actualizarUsuarioSeleccionado(dtoCompleto);
  }

  /// Cambiar estado (activar/desactivar)
  Future<void> cambiarEstado(UsuarioResponseDTO usuario, bool activar) async {
    try {
      if (activar) {
        await _service.activarUsuario(usuario.idUsuario);
      } else {
        await _service.desactivarUsuario(usuario.idUsuario);
      }
      await cargarUsuarios();
    } catch (e) {
      errorMessage = 'Error al cambiar estado: $e';
      notifyListeners();
    }
  }


  /// Obtener usuario por ID
  Future<void> obtenerUsuarioPorId(int idUsuario) async {
    try {
      usuarioSeleccionado = await _service.obtenerPorId(idUsuario);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al obtener usuario: $e';
      notifyListeners();
    }
  }

  Future<void> verDetallesUsuario(int idUsuario, BuildContext context) async {
    try {
      final u = await _service.obtenerPorId(idUsuario);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${u.nombres} ${u.apellidoPaterno} ${u.apellidoMaterno}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Correo: ${u.correo}'),
              Text('Rol: ${u.rol.nombre}'),
              Text('Estado: ${u.estado == true ? 'Activo' : 'Inactivo'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      errorMessage = 'No se pudo obtener el usuario: $e';
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    }
  }

  /// Obtener perfil del usuario autenticado (/me)
  Future<void> cargarPerfilAutenticado() async {
    try {
      usuarioAutenticado = await _service.obtenerPerfilAutenticado();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al obtener perfil autenticado: $e';
      notifyListeners();
    }
  }

  /// Cambiar contraseña del usuario autenticado
  Future<bool> actualizarPassword(ActualizarPasswordDTO dto) async {
    try {
      await _service.actualizarPassword(dto);
      return true;
    } catch (e) {
      errorMessage = 'Error al cambiar contraseña: $e';
      notifyListeners();
      return false;
    }
  }
}
