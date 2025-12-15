package com.unidadeducativa.personas.secretaria.service.impl;

import com.unidadeducativa.personas.secretaria.dto.SecretariaRequestDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaResponseDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaUpdateDTO;
import com.unidadeducativa.personas.secretaria.mapper.SecretariaMapper;
import com.unidadeducativa.personas.secretaria.model.Secretaria;
import com.unidadeducativa.personas.secretaria.repository.SecretariaRepository;
import com.unidadeducativa.personas.secretaria.service.ISecretariaService;
import com.unidadeducativa.exceptions.NotFoundException;
import com.unidadeducativa.shared.enums.RolNombre;
import com.unidadeducativa.usuario.model.Rol;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.RolRepository;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SecretariaServiceImpl implements ISecretariaService {

    private final SecretariaRepository secretariaRepository;
    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final SecretariaMapper secretariaMapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public List<SecretariaResponseDTO> listarSecretarias() {
        return secretariaRepository.findAll().stream()
                .map(secretariaMapper::toDTO)
                .toList();
    }

    @Override
    public SecretariaResponseDTO obtenerPorId(Long id) {
        Secretaria secretaria = secretariaRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Secretaria no encontrada con ID: " + id));
        return secretariaMapper.toDTO(secretaria);
    }

    @Override
    public SecretariaResponseDTO obtenerPorCorreo(String correo) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con correo: " + correo));
        Secretaria secretaria = secretariaRepository.findByUsuario(usuario)
                .orElseThrow(() -> new EntityNotFoundException("Secretaria no encontrada con usuario: " + correo));
        return secretariaMapper.toDTO(secretaria);
    }

    @Transactional
    @Override
    public SecretariaResponseDTO registrarSecretaria(SecretariaRequestDTO dto) {
        if (usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("Ya existe un usuario con el correo: " + dto.getCorreo());
        }

        if (secretariaRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe una secretaria con el CI: " + dto.getCi());
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 18 || edad > 80) {
                throw new IllegalArgumentException("La edad debe estar entre 18 y 80 años.");
            }
        }

        Rol rol = rolRepository.findByNombre(RolNombre.SECRETARIA)
                .orElseThrow(() -> new NotFoundException("No se encontró el rol SECRETARIA"));

        Usuario usuario = Usuario.builder()
                .nombres(dto.getNombres())
                .apellidoPaterno(dto.getApellidoPaterno())
                .apellidoMaterno(dto.getApellidoMaterno())
                .ci(dto.getCi())
                .correo(dto.getCorreo())
                .contrasena(passwordEncoder.encode(dto.getContrasena()))
                .fotoPerfil(dto.getFotoPerfil())
                .fechaNacimiento(dto.getFechaNacimiento())
                .estado(true)
                .rol(rol)
                .build();

        usuarioRepository.save(usuario);

        Secretaria secretaria = secretariaMapper.toEntity(dto);
        secretaria.setUsuario(usuario);
        secretariaRepository.save(secretaria);

        return secretariaMapper.toDTO(secretaria);
    }

    @Transactional
    @Override
    public SecretariaResponseDTO actualizarSecretaria(Long id, SecretariaUpdateDTO dto) {
        Secretaria secretaria = secretariaRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Secretaria no encontrada con ID: " + id));

        Usuario usuario = secretaria.getUsuario();

        if (!usuario.getCi().equals(dto.getCi())) {
            if (secretariaRepository.existsByUsuarioCi(dto.getCi())) {
                throw new IllegalArgumentException("Ya existe una secretaria con el CI: " + dto.getCi());
            }
            usuario.setCi(dto.getCi());
        }

        if (!usuario.getCorreo().equals(dto.getCorreo()) && usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("El correo ya está en uso por otro usuario.");
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 18 || edad > 80) {
                throw new IllegalArgumentException("La edad debe estar entre 18 y 80 años.");
            }
        }

        usuario.setNombres(dto.getNombres());
        usuario.setApellidoPaterno(dto.getApellidoPaterno());
        usuario.setApellidoMaterno(dto.getApellidoMaterno());
        usuario.setCi(dto.getCi());
        usuario.setCorreo(dto.getCorreo());
        usuario.setFotoPerfil(dto.getFotoPerfil());
        usuario.setFechaNacimiento(dto.getFechaNacimiento());
        usuarioRepository.save(usuario);

        secretariaMapper.updateFromDTO(dto, secretaria);
        secretariaRepository.save(secretaria);

        return secretariaMapper.toDTO(secretaria);
    }

    @Transactional
    @Override
    public SecretariaResponseDTO actualizarPorCorreo(String correo, SecretariaUpdateDTO dto) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado"));

        if (usuario.getRol().getNombre() != RolNombre.SECRETARIA) {
            throw new IllegalArgumentException("El usuario no corresponde a una secretaria");
        }

        Secretaria secretaria = secretariaRepository.findByUsuario(usuario)
                .orElseThrow(() -> new NotFoundException("Secretaria no encontrada asociada a este usuario"));

        if (!usuario.getCorreo().equals(dto.getCorreo()) && usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("El correo ya está en uso por otro usuario.");
        }

        if (!usuario.getCi().equals(dto.getCi()) && secretariaRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe una secretaria con el CI: " + dto.getCi());
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 18 || edad > 80) {
                throw new IllegalArgumentException("La edad de la secretaria debe estar entre 18 y 80 años.");
            }
        }

        usuario.setNombres(dto.getNombres());
        usuario.setApellidoPaterno(dto.getApellidoPaterno());
        usuario.setApellidoMaterno(dto.getApellidoMaterno());
        usuario.setCi(dto.getCi());
        usuario.setCorreo(dto.getCorreo());
        usuario.setFotoPerfil(dto.getFotoPerfil());
        usuario.setFechaNacimiento(dto.getFechaNacimiento());
        usuarioRepository.save(usuario);

        secretariaMapper.updateFromDTO(dto, secretaria);
        secretariaRepository.save(secretaria);
        return secretariaMapper.toDTO(secretaria);
    }

    @Transactional
    @Override
    public void eliminarSecretaria(Long id) {
        Secretaria secretaria = secretariaRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Secretaria no encontrada con ID: " + id));
        Usuario usuario = secretaria.getUsuario();
        secretariaRepository.delete(secretaria);
        usuarioRepository.delete(usuario);
    }

    @Override
    public void cambiarEstadoSecretaria(Long id, boolean estado) {
        Secretaria secretaria = secretariaRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Secretaria no encontrada con id: " + id));
        Usuario usuario = secretaria.getUsuario();
        usuario.setEstado(estado);
        usuarioRepository.save(usuario);
    }
}