package com.unidadeducativa.academia.materia.service.impl;

import com.unidadeducativa.academia.materia.dto.MateriaRequestDTO;
import com.unidadeducativa.academia.materia.dto.MateriaResponseDTO;
import com.unidadeducativa.academia.materia.mapper.MateriaMapper;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.materia.repository.MateriaRepository;
import com.unidadeducativa.academia.materia.service.IMateriaService;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import com.unidadeducativa.exceptions.NotFoundException; // Assuming this exists or use standard exception
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MateriaServiceImpl implements IMateriaService {

    private final MateriaRepository materiaRepository;
    private final MateriaMapper mapper;
    private final UsuarioRepository usuarioRepository;

    private Usuario obtenerUsuarioActual() {
        String correo = SecurityContextHolder.getContext().getAuthentication().getName();
        return usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado: " + correo));
    }

    @Override
    public MateriaResponseDTO crearMateria(MateriaRequestDTO dto) {
        if (materiaRepository.existsByNombreIgnoreCase(dto.getNombre())) {
            throw new IllegalArgumentException("Ya existe una materia con ese nombre");
        }

        Usuario usuarioActual = obtenerUsuarioActual();
        if (usuarioActual.getUnidadEducativa() == null) {
            throw new IllegalArgumentException("El usuario no pertenece a ninguna unidad educativa");
        }

        Materia materia = mapper.toEntity(dto);
        materia.setUnidadEducativa(usuarioActual.getUnidadEducativa());

        return mapper.toDTO(materiaRepository.save(materia));
    }

    @Override
    public MateriaResponseDTO actualizarMateria(Long id, MateriaRequestDTO dto) {
        Materia materia = materiaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Materia no encontrada"));

        // Verificar si hay otra materia con ese nombre
        boolean yaExiste = materiaRepository.existsByNombreIgnoreCase(dto.getNombre())
                && !dto.getNombre().equalsIgnoreCase(materia.getNombre());

        if (yaExiste) {
            throw new IllegalArgumentException("Ya existe otra materia con ese nombre");
        }

        materia.setNombre(dto.getNombre());
        // No cambiamos la unidad educativa al actualizar, se mantiene la original
        return mapper.toDTO(materiaRepository.save(materia));
    }

    @Override
    public MateriaResponseDTO obtenerMateria(Long id) {
        Materia materia = materiaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Materia no encontrada"));
        return mapper.toDTO(materia);
    }

    @Override
    public List<MateriaResponseDTO> listarMaterias() {
        return materiaRepository.findAll().stream()
                .map(mapper::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    public void eliminarMateria(Long id) {
        materiaRepository.deleteById(id);
    }
}
