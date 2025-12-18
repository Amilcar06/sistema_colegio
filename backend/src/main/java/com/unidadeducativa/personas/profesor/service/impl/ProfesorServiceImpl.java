package com.unidadeducativa.personas.profesor.service.impl;

import com.unidadeducativa.exceptions.NotFoundException;
import com.unidadeducativa.personas.profesor.dto.ProfesorRequestDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorResponseDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorUpdateDTO;
import com.unidadeducativa.personas.profesor.mapper.ProfesorMapper;
import com.unidadeducativa.personas.profesor.model.Profesor;
import com.unidadeducativa.personas.profesor.repository.ProfesorRepository;
import com.unidadeducativa.personas.profesor.service.IProfesorService;
import com.unidadeducativa.shared.enums.RolNombre;
import com.unidadeducativa.usuario.model.Rol;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.RolRepository;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProfesorServiceImpl implements IProfesorService {

    private final ProfesorRepository profesorRepository;
    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final ProfesorMapper profesorMapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public List<ProfesorResponseDTO> listarProfesores(Boolean estado) {
        List<Profesor> profesores = (estado == null)
                ? profesorRepository.findAll()
                : profesorRepository.findByUsuario_Estado(estado);
        return profesores.stream()
                .map(profesorMapper::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    public ProfesorResponseDTO obtenerPorId(Long id) {
        Profesor profesor = profesorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Profesor no encontrado con ID: " + id));
        return profesorMapper.toDTO(profesor);
    }

    @Override
    public ProfesorResponseDTO obtenerPorCorreo(String correo) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado con correo: " + correo));
        Profesor profesor = profesorRepository.findByUsuario(usuario)
                .orElseThrow(() -> new NotFoundException("Profesor no encontrado con usuario: " + correo));
        return profesorMapper.toDTO(profesor);
    }

    @Transactional
    @Override
    public ProfesorResponseDTO registrarProfesorCompleto(ProfesorRequestDTO dto) {
        if (usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("Ya existe un usuario con el correo: " + dto.getCorreo());
        }
        if (profesorRepository.existsByUsuarioCi(dto.getCi())) {
            throw new IllegalArgumentException("Ya existe un profesor con el CI: " + dto.getCi());
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 18 || edad > 80) {
                throw new IllegalArgumentException("La edad del profesor debe estar entre 18 y 80 años.");
            }
        }

        Rol rol = rolRepository.findByNombre(RolNombre.PROFESOR)
                .orElseThrow(() -> new NotFoundException("No se encontró el rol PROFESOR"));

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

        // Asignar Unidad Educativa del creador
        try {
            String correoCreador = org.springframework.security.core.context.SecurityContextHolder.getContext()
                    .getAuthentication().getName();
            if (correoCreador != null && !correoCreador.equals("anonymousUser")) {
                Usuario creador = usuarioRepository.findByCorreo(correoCreador).orElse(null);
                if (creador != null && creador.getUnidadEducativa() != null) {
                    usuario.setUnidadEducativa(creador.getUnidadEducativa());
                    System.out.println("DEBUG: Asignando UE " + creador.getUnidadEducativa().getIdUnidadEducativa()
                            + " a nuevo profesor (creado por " + correoCreador + ")");
                } else {
                    System.out.println("WARNING: Creador " + correoCreador + " no tiene UE o es nulo.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        usuarioRepository.save(usuario);

        Profesor profesor = profesorMapper.toEntity(dto);
        profesor.setUsuario(usuario);

        Profesor guardado = profesorRepository.save(profesor);
        return profesorMapper.toDTO(guardado);
    }

    @Transactional
    @Override
    public ProfesorResponseDTO actualizarProfesor(Long id, ProfesorUpdateDTO dto) {
        Profesor profesor = profesorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Profesor no encontrado con ID: " + id));
        Usuario usuario = profesor.getUsuario();

        if (!usuario.getCi().equals(dto.getCi())) {
            if (profesorRepository.existsByUsuarioCi(dto.getCi())) {
                throw new IllegalArgumentException("Ya existe un profesor con el CI: " + dto.getCi());
            }
            usuario.setCi(dto.getCi());
        }

        if (!usuario.getCorreo().equals(dto.getCorreo()) && usuarioRepository.existsByCorreo(dto.getCorreo())) {
            throw new IllegalArgumentException("El correo ya está en uso por otro usuario.");
        }

        if (dto.getFechaNacimiento() != null) {
            int edad = Period.between(dto.getFechaNacimiento(), LocalDate.now()).getYears();
            if (edad < 18 || edad > 80) {
                throw new IllegalArgumentException("La edad del profesor debe estar entre 18 y 80 años.");
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

        profesorMapper.updateFromDTO(dto, profesor);
        profesorRepository.save(profesor);

        return profesorMapper.toDTO(profesor);
    }

    @Transactional
    @Override
    public ProfesorResponseDTO actualizarPorCorreo(String correo, ProfesorUpdateDTO dto) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado con correo: " + correo));

        if (usuario.getRol().getNombre() != RolNombre.PROFESOR) {
            throw new IllegalArgumentException("El usuario no corresponde a un profesor");
        }

        Profesor profesor = profesorRepository.findByUsuario(usuario)
                .orElseThrow(() -> new NotFoundException("Profesor no encontrado asociado a este usuario"));

        return actualizarProfesor(profesor.getIdProfesor(), dto);
    }

    @Transactional
    @Override
    public void eliminarProfesor(Long id) {
        Profesor profesor = profesorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Profesor no encontrado con ID: " + id));
        Usuario usuario = profesor.getUsuario();
        profesorRepository.delete(profesor);
        usuarioRepository.delete(usuario);
    }

    @Override
    public void cambiarEstadoProfesor(Long id, boolean estado) {
        Profesor profesor = profesorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Profesor no encontrado con ID: " + id));
        Usuario usuario = profesor.getUsuario();
        usuario.setEstado(estado);
        usuarioRepository.save(usuario);
    }
}
