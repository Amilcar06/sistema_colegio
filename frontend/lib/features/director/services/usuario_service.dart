import 'package:unidad_educatica_frontend/core/api.dart';
import '../models/usuario_request.dart';
import '../models/usuario_response.dart';
import '../models/actualizar_password.dart';
import '../models/usuario_sin_rol_request.dart';

class UsuarioService {
  /// Registrar un director (se asigna automáticamente el rol en el backend)
  Future<UsuarioResponseDTO> registrarDirector(UsuarioSinRolRequestDTO dto) async {
    final response = await dio.post('/usuarios/registro-director', data: dto.toJson());
    return UsuarioResponseDTO.fromJson(response.data);
  }

  /// Registrar una secretaria (se asigna automáticamente el rol en el backend)
  Future<UsuarioResponseDTO> registrarSecretaria(UsuarioSinRolRequestDTO dto) async {
    final response = await dio.post('/usuarios/registro-secretaria', data: dto.toJson());
    return UsuarioResponseDTO.fromJson(response.data);
  }

  /// Registrar un usuario genérico con rol especificado (idRol)
  Future<UsuarioResponseDTO> registrarUsuario(UsuarioRequestDTO dto) async {
    final response = await dio.post('/usuarios', data: dto.toJson());
    return UsuarioResponseDTO.fromJson(response.data);
  }

  /// Listar todos los usuarios
  Future<List<UsuarioResponseDTO>> listarUsuarios() async {
    final response = await dio.get('/usuarios');
    return (response.data as List)
        .map((e) => UsuarioResponseDTO.fromJson(e))
        .toList();
  }

  /// Listar todos los usuarios
  Future<List<UsuarioResponseDTO>> listarUsuariosSecretarias() async {
    final response = await dio.get('/usuarios/secretarias');
    return (response.data as List)
        .map((e) => UsuarioResponseDTO.fromJson(e))
        .toList();
  }

  /// Obtener un usuario por su ID
  Future<UsuarioResponseDTO> obtenerPorId(int idUsuario) async {
    final response = await dio.get('/usuarios/$idUsuario');
    return UsuarioResponseDTO.fromJson(response.data);
  }

  /// Actualizar un usuario por ID
  Future<UsuarioResponseDTO> actualizarUsuario(int idUsuario, UsuarioRequestDTO dto) async {
    final response = await dio.put('/usuarios/$idUsuario', data: dto.toJson());
    return UsuarioResponseDTO.fromJson(response.data);
  }

  /// Cambiar estado del usuario (campo booleano `estado`)
  Future<void> activarUsuario(int idUsuario) async {
    await dio.put('/usuarios/$idUsuario/activar');
  }

  Future<void> desactivarUsuario(int idUsuario) async {
    await dio.put('/usuarios/$idUsuario/desactivar');
  }

  /// Eliminar lógicamente un usuario
  Future<void> eliminarUsuario(int idUsuario) async {
    await dio.delete('/usuarios/$idUsuario');
  }

  /// Obtener perfil del usuario autenticado (`/me`)
  Future<UsuarioResponseDTO> obtenerPerfilAutenticado() async {
    final response = await dio.get('/usuarios/me');
    return UsuarioResponseDTO.fromJson(response.data);
  }

  /// Actualizar contraseña del usuario autenticado
  Future<void> actualizarPassword(ActualizarPasswordDTO dto) async {
    await dio.put('/usuarios/password', data: dto.toJson());
  }
}
