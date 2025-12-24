package com.unidadeducativa.personas.estudiante.service.impl;

import lombok.extern.slf4j.Slf4j;
import com.unidadeducativa.exceptions.NotFoundException;
import com.unidadeducativa.personas.estudiante.dto.EstudianteRequestDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteResponseDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteUpdateDTO;
import com.unidadeducativa.personas.estudiante.mapper.EstudianteMapper;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.personas.estudiante.service.IEstudianteService;
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

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.time.LocalDate;
import java.time.Period;
import java.util.List;
import java.util.stream.Collectors;

import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class EstudianteServiceImpl implements IEstudianteService {

    private final EstudianteRepository estudianteRepository;
    private final UsuarioRepository usuarioRepository;
    private final EstudianteMapper estudianteMapper;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;
    private final InscripcionRepository inscripcionRepository;

    @Override
    public Page<EstudianteResponseDTO> listarEstudiantes(Boolean estado, Pageable pageable) {
        Page<Estudiante> estudiantes = (estado == null)
                ? estudianteRepository.findAll(pageable)
                : estudianteRepository.findByUsuarioEstado(estado, pageable);

        return estudiantes.map(estudiante -> {
            EstudianteResponseDTO dto = estudianteMapper.toDTO(estudiante);
            // Optimization: Do not send base64 photo in lists
            dto.setFotoPerfil(null);
            return dto;
        });
    }

    @Override
    public List<com.unidadeducativa.academia.gestion.dto.GestionResponseDTO> listarGestionesEstudiante(
            Long idEstudiante) {
        return inscripcionRepository.findByEstudianteIdEstudiante(idEstudiante).stream()
                .map(inscripcion -> {
                    var gestion = inscripcion.getGestion();
                    return com.unidadeducativa.academia.gestion.dto.GestionResponseDTO.builder()
                            .idGestion(gestion.getIdGestion())
                            .anio(gestion.getAnio())
                            .estado(gestion.getEstado())
                            .build();
                })
                .distinct()
                .collect(Collectors.toList());
    }

    @Override
    public EstudianteResponseDTO obtenerPorId(Long id) {
        Estudiante estudiante = estudianteRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Estudiante no encontrado con id: " + id));
        return estudianteMapper.toDTO(estudiante);
    }

    @Override
    public EstudianteResponseDTO obtenerPorCorreo(String correo) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new EntityNotFoundException("Usuario no encontrado con correo: " + correo));
        Estudiante estudiante = estudianteRepository.findByUsuario(usuario)
                .orElseThrow(() -> new EntityNotFoundException("Estudiante no encontrado con usuario: " + correo));
        return estudianteMapper.toDTO(estudiante);
    }

    @Transactional
    @Override
    public EstudianteResponseDTO registrarEstudianteCompleto(EstudianteRequestDTO dto) {
        if (usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("Ya existe un usuario con el correo: " + dto.getCorreo());
        }
        if (estudianteRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un estudiante con el CI: " + dto.getCi());
        }

        validarEdad(dto.getFechaNacimiento());

        Rol rol = rolRepository.findByNombre(RolNombre.ESTUDIANTE)
                .orElseThrow(() -> new NotFoundException("No se encontró el rol ESTUDIANTE"));

        Usuario usuario = Usuario.builder()
                .nombres(dto.getNombres())
                .apellidoPaterno(dto.getApellidoPaterno())
                .apellidoMaterno(dto.getApellidoMaterno())
                .ci(dto.getCi())
                .correo(dto.getCorreo())
                .correo(dto.getCorreo())
                .contrasena(passwordEncoder.encode(
                        (dto.getContrasena() == null || dto.getContrasena().isBlank())
                                ? dto.getCi()
                                : dto.getContrasena()))
                .fotoPerfil(dto.getFotoPerfil())
                .fechaNacimiento(dto.getFechaNacimiento())
                .estado(true)
                .rol(rol)
                .estado(true)
                .rol(rol)
                .build();

        // Asignar Unidad Educativa del creador (Director/Admin)
        try {
            String correoCreador = org.springframework.security.core.context.SecurityContextHolder.getContext()
                    .getAuthentication().getName();
            if (correoCreador != null && !correoCreador.equals("anonymousUser")) {
                Usuario creador = usuarioRepository.findByCorreo(correoCreador).orElse(null);
                if (creador != null && creador.getUnidadEducativa() != null) {
                    usuario.setUnidadEducativa(creador.getUnidadEducativa());
                    System.out.println("DEBUG: Asignando UE " + creador.getUnidadEducativa().getIdUnidadEducativa()
                            + " a nuevo estudiante (creado por " + correoCreador + ")");
                } else {
                    System.out.println("WARNING: Creador " + correoCreador + " no tiene UE o no existe.");
                }
            } else {
                System.out.println("No hay contexto de seguridad o es anonymousUser");
            }
        } catch (Exception e) {
            log.error("Error asignando Unidad Educativa del creador", e);
            // Ignorar si no hay contexto de seguridad (ej. Seeder)
        }

        usuarioRepository.save(usuario);

        Estudiante estudiante = estudianteMapper.toEntity(dto);
        estudiante.setUsuario(usuario);

        Estudiante guardado = estudianteRepository.save(estudiante);
        return estudianteMapper.toDTO(guardado);
    }

    @Transactional
    @Override
    public EstudianteResponseDTO actualizarEstudiante(Long id, EstudianteUpdateDTO dto) {
        Estudiante estudiante = estudianteRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Estudiante no encontrado con id: " + id));
        Usuario usuario = estudiante.getUsuario();

        if (!usuario.getCi().equals(dto.getCi()) && estudianteRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un estudiante con el CI: " + dto.getCi());
        }

        if (!usuario.getCorreo().equals(dto.getCorreo()) && usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("El correo ya está en uso por otro usuario.");
        }

        validarEdad(dto.getFechaNacimiento());

        usuario.setNombres(dto.getNombres());
        usuario.setApellidoPaterno(dto.getApellidoPaterno());
        usuario.setApellidoMaterno(dto.getApellidoMaterno());
        usuario.setCi(dto.getCi());
        usuario.setCi(dto.getCi());
        usuario.setCorreo(dto.getCorreo());
        if (dto.getContrasena() != null && !dto.getContrasena().isBlank()) {
            usuario.setContrasena(passwordEncoder.encode(dto.getContrasena()));
        }
        usuario.setFotoPerfil(dto.getFotoPerfil());
        usuario.setFechaNacimiento(dto.getFechaNacimiento());
        usuarioRepository.save(usuario);

        estudianteMapper.updateFromDTO(dto, estudiante);
        estudianteRepository.save(estudiante);
        return estudianteMapper.toDTO(estudiante);
    }

    @Transactional
    @Override
    public EstudianteResponseDTO actualizarPorCorreo(String correo, EstudianteUpdateDTO dto) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado"));

        if (usuario.getRol().getNombre() != RolNombre.ESTUDIANTE) {
            throw new IllegalArgumentException("El usuario no corresponde a un estudiante");
        }

        Estudiante estudiante = estudianteRepository.findByUsuario(usuario)
                .orElseThrow(() -> new NotFoundException("Estudiante no encontrado asociado a este usuario"));

        if (!usuario.getCorreo().equals(dto.getCorreo()) && usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("El correo ya está en uso por otro usuario.");
        }

        if (!usuario.getCi().equals(dto.getCi()) && estudianteRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un estudiante con el CI: " + dto.getCi());
        }

        validarEdad(dto.getFechaNacimiento());

        usuario.setNombres(dto.getNombres());
        usuario.setApellidoPaterno(dto.getApellidoPaterno());
        usuario.setApellidoMaterno(dto.getApellidoMaterno());
        usuario.setCi(dto.getCi());
        usuario.setCorreo(dto.getCorreo());
        usuario.setFotoPerfil(dto.getFotoPerfil());
        usuario.setFechaNacimiento(dto.getFechaNacimiento());
        usuarioRepository.save(usuario);

        estudianteMapper.updateFromDTO(dto, estudiante);
        estudianteRepository.save(estudiante);
        return estudianteMapper.toDTO(estudiante);
    }

    @Transactional
    @Override
    public void eliminarEstudiante(Long id) {
        Estudiante estudiante = estudianteRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Estudiante no encontrado con id: " + id));
        Usuario usuario = estudiante.getUsuario();
        estudianteRepository.delete(estudiante);
        usuarioRepository.delete(usuario);
    }

    @Override
    public void cambiarEstadoEstudiante(Long id, boolean estado) {
        Estudiante estudiante = estudianteRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Estudiante no encontrado con id: " + id));
        Usuario usuario = estudiante.getUsuario();
        usuario.setEstado(estado);
        usuarioRepository.save(usuario);
    }

    private void validarEdad(LocalDate fechaNacimiento) {
        if (fechaNacimiento != null) {
            int edad = Period.between(fechaNacimiento, LocalDate.now()).getYears();
            if (edad < 3 || edad > 25) {
                throw new IllegalArgumentException("La edad del estudiante debe estar entre 3 y 25 años.");
            }
        }
    }
}
