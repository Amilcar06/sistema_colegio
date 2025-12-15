package com.unidadeducativa.personas.director.service.impl;

import com.unidadeducativa.personas.director.dto.DirectorRequestDTO;
import com.unidadeducativa.personas.director.dto.DirectorResponseDTO;
import com.unidadeducativa.personas.director.dto.DirectorUpdateDTO;
import com.unidadeducativa.personas.director.mapper.DirectorMapper;
import com.unidadeducativa.personas.director.model.Director;
import com.unidadeducativa.personas.director.repository.DirectorRepository;
import com.unidadeducativa.personas.director.service.IDirectorService;
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
public class DirectorServiceImpl implements IDirectorService {

    private final DirectorRepository directorRepository;
    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final DirectorMapper directorMapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public List<DirectorResponseDTO> listarDirectores() {
        return directorRepository.findAll().stream()
                .map(directorMapper::toDTO)
                .toList();
    }

    @Override
    public DirectorResponseDTO obtenerPorId(Long id) {
        Director director = directorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Director no encontrado con ID: " + id));
        return directorMapper.toDTO(director);
    }

    @Override
    public DirectorResponseDTO obtenerPorCorreo(String correo) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con correo: " + correo));
        Director director = directorRepository.findByUsuario(usuario)
                .orElseThrow(() -> new EntityNotFoundException("Director no encontrado con usuario: " + correo));
        return directorMapper.toDTO(director);
    }

    @Transactional
    @Override
    public DirectorResponseDTO registrarDirector(DirectorRequestDTO dto) {
        if (usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("Ya existe un usuario con el correo: " + dto.getCorreo());
        }

        if (directorRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un director con el CI: " + dto.getCi());
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 25) {
                throw new IllegalArgumentException("La edad debe estar entre 25 y 80 años.");
            }
        }

        Rol rol = rolRepository.findByNombre(RolNombre.DIRECTOR)
                .orElseThrow(() -> new NotFoundException("No se encontró el rol DIRECTOR"));

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

        Director director = directorMapper.toEntity(dto);
        director.setUsuario(usuario);
        directorRepository.save(director);

        return directorMapper.toDTO(director);
    }

    @Transactional
    @Override
    public DirectorResponseDTO actualizarDirector(Long id, DirectorUpdateDTO dto) {
        Director director = directorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Director no encontrado con ID: " + id));

        Usuario usuario = director.getUsuario();

        if (!usuario.getCi().equals(dto.getCi())) {
            if (directorRepository.existsByUsuarioCi(dto.getCi())) {
                throw new IllegalArgumentException("Ya existe un director con el CI: " + dto.getCi());
            }
            usuario.setCi(dto.getCi());
        }

        if (!usuario.getCorreo().equals(dto.getCorreo()) && usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("El correo ya está en uso por otro usuario.");
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 25 || edad > 80) {
                throw new IllegalArgumentException("La edad debe estar entre 25 y 80 años.");
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

        directorMapper.updateFromDTO(dto, director);
        directorRepository.save(director);

        return directorMapper.toDTO(director);
    }

    @Transactional
    @Override
    public DirectorResponseDTO actualizarPorCorreo(String correo, DirectorUpdateDTO dto) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado"));

        if (usuario.getRol().getNombre() != RolNombre.DIRECTOR) {
            throw new IllegalArgumentException("El usuario no corresponde a un estudiante");
        }

        Director director = directorRepository.findByUsuario(usuario)
                .orElseThrow(() -> new NotFoundException("Director no encontrado asociado a este usuario"));

        if (!usuario.getCorreo().equals(dto.getCorreo()) && usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("El correo ya está en uso por otro usuario.");
        }

        if (!usuario.getCi().equals(dto.getCi()) && directorRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un director con el CI: " + dto.getCi());
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 25 || edad > 80) {
                throw new IllegalArgumentException("La edad del director debe estar entre 25 y 80 años.");
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

        directorMapper.updateFromDTO(dto, director);
        directorRepository.save(director);
        return directorMapper.toDTO(director);
    }

    @Transactional
    @Override
    public void eliminarDirector(Long id) {
        Director director = directorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Director no encontrado con ID: " + id));
        Usuario usuario = director.getUsuario();
        directorRepository.delete(director);
        usuarioRepository.delete(usuario);
    }

    @Override
    public void cambiarEstadoDirector(Long id, boolean estado) {
        Director director = directorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Estudiante no encontrado con id: " + id));
        Usuario usuario = director.getUsuario();
        usuario.setEstado(estado);
        usuarioRepository.save(usuario);
    }
}
