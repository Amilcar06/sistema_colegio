package com.unidadeducativa.usuario.service;

import com.unidadeducativa.usuario.dto.PasswordUpdateDTO;
import com.unidadeducativa.usuario.dto.UsuarioRequestDTO;
import com.unidadeducativa.usuario.dto.UsuarioResponseDTO;
import com.unidadeducativa.usuario.dto.UsuarioSinRolRequestDTO;
import com.unidadeducativa.usuario.dto.UsuarioUpdateDTO;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;

public interface IUsuarioService {
    // BÁSICOS
    Page<UsuarioResponseDTO> listarUsuarios(Pageable pageable);

    UsuarioResponseDTO obtenerPorId(Long id);

    UsuarioResponseDTO crearUsuario(UsuarioRequestDTO dto);

    UsuarioResponseDTO actualizarUsuario(Long id, UsuarioUpdateDTO dto);

    void eliminarUsuario(Long id);

    // ENDPOINTS ESPECIFICOS PARA EL FRONTEND (DIRECTOR)
    Page<UsuarioResponseDTO> listarUsuariosSecretarias(Pageable pageable); // Lista Admins, Directores y Secretarias

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
