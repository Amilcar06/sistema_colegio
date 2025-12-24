import 'package:dio/dio.dart';
import 'package:unidad_educatica_frontend/core/api.dart';
import '../models/usuario_request.dart';
import '../models/usuario_response.dart';
import 'package:unidad_educatica_frontend/shared/models/page_response.dart';
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
    return (response.data['content'] != null)
        ? (response.data['content'] as List).map((e) => UsuarioResponseDTO.fromJson(e)).toList()
        : (response.data as List).map((e) => UsuarioResponseDTO.fromJson(e)).toList();
  }

  Future<PageResponse<UsuarioResponseDTO>> listarUsuariosPaginated({int page = 0, int size = 20}) async {
    final response = await dio.get('/usuarios', queryParameters: {'page': page, 'size': size});
    return PageResponse<UsuarioResponseDTO>.fromJson(
      response.data,
      (json) => UsuarioResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Listar todos los usuarios
  Future<List<UsuarioResponseDTO>> listarUsuariosSecretarias() async {
    final response = await dio.get('/usuarios/secretarias');
    return (response.data['content'] != null)
        ? (response.data['content'] as List).map((e) => UsuarioResponseDTO.fromJson(e)).toList()
        : (response.data as List).map((e) => UsuarioResponseDTO.fromJson(e)).toList();
  }

  Future<PageResponse<UsuarioResponseDTO>> listarUsuariosSecretariasPaginated({int page = 0, int size = 20}) async {
    final response = await dio.get('/usuarios/secretarias', queryParameters: {'page': page, 'size': size});
    return PageResponse<UsuarioResponseDTO>.fromJson(
      response.data,
      (json) => UsuarioResponseDTO.fromJson(json as Map<String, dynamic>),
    );
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

  Future<void> actualizarPassword(ActualizarPasswordDTO dto) async {
    await dio.put('/usuarios/me/contrasena', data: dto.toJson());
  }

  Future<UsuarioResponseDTO> actualizarPerfil(UsuarioRequestDTO dto) async {
    final response = await dio.put('/usuarios/me', data: dto.toJson());
    return UsuarioResponseDTO.fromJson(response.data);
  }

  /// Subir foto de perfil
  Future<String> subirFotoPerfil(dynamic file) async {
    // Nota: 'file' puede ser File (Mobile) o Uint8List (Web) o XFile. 
    // Ajustar según implementación de image_picker.
    // Asumiendo File para mobile por ahora.
    
    // Importante: Para Web se usa bytes, para IO se usa path. 
    // dio.MultipartFile.fromFile vs MultipartFile.fromBytes
    
    // Simplificación para mobile (path):
    /*
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    */
    
    // Si usamos XFile de image_picker:
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
    });

    final response = await dio.post('/uploads/perfil', data: formData);
    return response.data['url'];
  }
}
