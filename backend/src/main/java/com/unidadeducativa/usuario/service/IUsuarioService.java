package com.unidadeducativa.usuario.service;

import com.unidadeducativa.usuario.dto.PasswordUpdateDTO;
import com.unidadeducativa.usuario.dto.UsuarioRequestDTO;
import com.unidadeducativa.usuario.dto.UsuarioResponseDTO;
import com.unidadeducativa.usuario.dto.UsuarioSinRolRequestDTO;
import com.unidadeducativa.usuario.dto.UsuarioUpdateDTO;
import jakarta.validation.Valid;
import java.util.List;

public interface IUsuarioService {
    // BÁSICOS
    List<UsuarioResponseDTO> listarUsuarios();

    UsuarioResponseDTO obtenerPorId(Long id);

    UsuarioResponseDTO crearUsuario(UsuarioRequestDTO dto);

    UsuarioResponseDTO actualizarUsuario(Long id, UsuarioUpdateDTO dto);

    void eliminarUsuario(Long id);

    // ENDPOINTS ESPECIFICOS PARA EL FRONTEND (DIRECTOR)
    List<UsuarioResponseDTO> listarUsuariosSecretarias(); // Lista Admins, Directores y Secretarias

    UsuarioResponseDTO registrarDirector(UsuarioSinRolRequestDTO dto);

    UsuarioResponseDTO registrarSecretaria(UsuarioSinRolRequestDTO dto);

    // PARA EL USUARIO LOGUEADO
    UsuarioResponseDTO obtenerUsuarioActual(); // /me

    void cambiarPasswordActual(PasswordUpdateDTO dto);

    // UTILITARIOS
    UsuarioResponseDTO obtenerPorCorreo(String correo);

    void cambiarEstadoUsuario(Long id, boolean estado);

    UsuarioResponseDTO actualizarPerfilActual(@Valid UsuarioUpdateDTO dto);
}
