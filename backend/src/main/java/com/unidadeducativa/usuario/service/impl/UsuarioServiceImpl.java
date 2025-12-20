package com.unidadeducativa.usuario.service.impl;

import com.unidadeducativa.usuario.dto.*;
import com.unidadeducativa.usuario.mapper.UsuarioMapper;
import com.unidadeducativa.usuario.model.Rol;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.RolRepository;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import com.unidadeducativa.usuario.service.IUsuarioService;
import com.unidadeducativa.usuario.service.IRolService; // ADDED
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UsuarioServiceImpl implements IUsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final UsuarioMapper usuarioMapper;
    private final PasswordEncoder passwordEncoder;

    // ========================
    // CRUD BÁSICO DE USUARIOS
    // ========================

    @Override
    public List<UsuarioResponseDTO> listarUsuarios() {
        return usuarioRepository.findAll()
                .stream()
                .map(usuarioMapper::toDTO)
                .toList();
    }

    @Override
    public UsuarioResponseDTO obtenerPorId(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con ID: " + id));
        return usuarioMapper.toDTO(usuario);
    }

    @Override
    public UsuarioResponseDTO crearUsuario(UsuarioRequestDTO dto) {
        if (usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("Ya existe un usuario con el correo: " + dto.getCorreo());
        }

        if (usuarioRepository.existsByCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un usuario con el CI: " + dto.getCi());
        }

        Usuario usuario = usuarioMapper.toEntity(dto);
        usuario.setContrasena(passwordEncoder.encode(dto.getContrasena()));

        Rol rol = rolRepository.findById(dto.getIdRol())
                .orElseThrow(() -> new EntityNotFoundException("Rol no encontrado con ID: " + dto.getIdRol()));
        usuario.setRol(rol);

        usuarioRepository.save(usuario);
        return usuarioMapper.toDTO(usuario);
    }

    @Override
    public UsuarioResponseDTO actualizarUsuario(Long id, UsuarioUpdateDTO dto) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con ID: " + id));

        // Validar CI duplicado si se envió un nuevo CI
        if (dto.getCi() != null && !dto.getCi().equals(usuario.getCi())) {
            if (usuarioRepository.existsByCi(dto.getCi())) {
                throw new IllegalArgumentException("Ya existe un usuario con el CI: " + dto.getCi());
            }
            usuario.setCi(dto.getCi());
        }

        if (dto.getContrasena() != null && !dto.getContrasena().isBlank()) {
            usuario.setContrasena(passwordEncoder.encode(dto.getContrasena()));
        }

        usuarioMapper.updateFromDTO(dto, usuario);
        usuarioRepository.save(usuario);
        return usuarioMapper.toDTO(usuario);
    }

    @Override
    public void eliminarUsuario(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con ID: " + id));
        usuarioRepository.delete(usuario);
    }

    // ==========================================
    // IMPLEMENTACION METODOS ESPECIFICOS FRONTEND
    // ==========================================

    @Override
    public List<UsuarioResponseDTO> listarUsuariosSecretarias() {
        // Retornar usuarios con rol ADMIN, DIRECTOR o SECRETARIA
        // Podriamos hacerlo con una query custom JPA, o filtrando en stream (menos
        // eficiente pero rapido de implementar ahora)
        return usuarioRepository.findAll().stream()
                .filter(u -> {
                    String r = u.getRol().getNombre().name().toUpperCase();
                    return r.equals("ADMIN") || r.equals("DIRECTOR") || r.equals("SECRETARIA");
                })
                .map(usuarioMapper::toDTO)
                .toList();
    }

    @Override
    public UsuarioResponseDTO registrarDirector(UsuarioSinRolRequestDTO dto) {
        return registrarUsuarioConRolEspecifico(dto, "DIRECTOR");
    }

    @Override
    public UsuarioResponseDTO registrarSecretaria(UsuarioSinRolRequestDTO dto) {
        return registrarUsuarioConRolEspecifico(dto, "SECRETARIA");
    }

    private UsuarioResponseDTO registrarUsuarioConRolEspecifico(UsuarioSinRolRequestDTO dto, String nombreRol) {
        if (usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("Ya existe un usuario con el correo: " + dto.getCorreo());
        }
        if (usuarioRepository.existsByCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un usuario con el CI: " + dto.getCi());
        }

        Usuario usuario = new Usuario();
        usuario.setNombres(dto.getNombres());
        usuario.setApellidoPaterno(dto.getApellidoPaterno());
        usuario.setApellidoMaterno(dto.getApellidoMaterno());
        usuario.setCi(dto.getCi());
        usuario.setCorreo(dto.getCorreo());
        usuario.setContrasena(passwordEncoder.encode(dto.getContrasena()));
        usuario.setFotoPerfil(dto.getFotoPerfil());
        usuario.setEstado(true); // Por defecto activo

        // Buscar el Rol por nombre
        Rol rol = rolRepository.findAll().stream()
                .filter(r -> r.getNombre().name().equalsIgnoreCase(nombreRol))
                .findFirst()
                .orElseThrow(() -> new EntityNotFoundException("Rol " + nombreRol + " no encontrado en BD"));

        usuario.setRol(rol);
        // id_unidad_educativa? Asumimos null o por defecto si no es requerido.

        usuarioRepository.save(usuario);
        return usuarioMapper.toDTO(usuario);
    }

    // ==========================
    // USUARIO AUTENTICADO (/me)
    // ==========================

    @Override
    public UsuarioResponseDTO obtenerUsuarioActual() {
        String correo = SecurityContextHolder.getContext().getAuthentication().getName();
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new EntityNotFoundException("Usuario autenticado no encontrado"));
        return usuarioMapper.toDTO(usuario);
    }

    @Override
    public UsuarioResponseDTO actualizarPerfilActual(UsuarioUpdateDTO dto) {
        String correo = SecurityContextHolder.getContext().getAuthentication().getName();
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new EntityNotFoundException("Usuario autenticado no encontrado"));

        if (dto.getCi() != null && !dto.getCi().equals(usuario.getCi())) {
            if (usuarioRepository.existsByCi(dto.getCi())) {
                throw new IllegalArgumentException("Ya existe un usuario con el CI: " + dto.getCi());
            }
            usuario.setCi(dto.getCi());
        }

        usuarioMapper.updateFromDTO(dto, usuario);
        usuarioRepository.save(usuario);
        return usuarioMapper.toDTO(usuario);
    }

    @Override
    public void cambiarPasswordActual(PasswordUpdateDTO dto) {
        String correo = SecurityContextHolder.getContext().getAuthentication().getName();
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new EntityNotFoundException("Usuario autenticado no encontrado"));

        if (!passwordEncoder.matches(dto.getPasswordActual(), usuario.getContrasena())) {
            throw new IllegalArgumentException("La contraseña actual es incorrecta");
        }

        usuario.setContrasena(passwordEncoder.encode(dto.getNuevaPassword()));
        usuarioRepository.save(usuario);
    }

    // ========================
    // UTILITARIOS
    // ========================

    @Override
    public UsuarioResponseDTO obtenerPorCorreo(String correo) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con correo: " + correo));
        return usuarioMapper.toDTO(usuario);
    }

    @Override
    public void cambiarEstadoUsuario(Long id, boolean estado) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con ID: " + id));
        usuario.setEstado(estado);
        usuarioRepository.save(usuario);
    }
}
