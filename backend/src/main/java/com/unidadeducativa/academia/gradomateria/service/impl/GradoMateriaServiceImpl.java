package com.unidadeducativa.academia.gradomateria.service.impl;

import com.unidadeducativa.academia.gradomateria.dto.GradoMateriaRequestDTO;
import com.unidadeducativa.academia.gradomateria.dto.GradoMateriaResponseDTO;
import com.unidadeducativa.academia.gradomateria.mapper.GradoMateriaMapper;
import com.unidadeducativa.academia.gradomateria.model.GradoMateria;
import com.unidadeducativa.academia.gradomateria.repository.GradoMateriaRepository;
import com.unidadeducativa.academia.gradomateria.service.IGradoMateriaService;
import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.academia.grado.repository.GradoRepository;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.materia.repository.MateriaRepository;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.gestion.repository.GestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GradoMateriaServiceImpl implements IGradoMateriaService {

    private final GradoMateriaRepository repository;
    private final GradoMateriaMapper mapper;
    private final GradoRepository gradoRepository;
    private final MateriaRepository materiaRepository;
    private final GestionRepository gestionRepository;

    @Override
    public GradoMateriaResponseDTO crear(GradoMateriaRequestDTO dto) {
        if (repository.existsByGrado_IdGradoAndMateria_IdMateriaAndGestion_IdGestion(
                dto.getIdGrado(), dto.getIdMateria(), dto.getIdGestion())) {
            throw new IllegalArgumentException("Ya existe esa combinación de grado, materia y gestión");
        }

        Grado grado = gradoRepository.findById(dto.getIdGrado())
                .orElseThrow(() -> new RuntimeException("Grado no encontrado"));
        Materia materia = materiaRepository.findById(dto.getIdMateria())
                .orElseThrow(() -> new RuntimeException("Materia no encontrada"));
        GestionAcademica gestion = gestionRepository.findById(dto.getIdGestion())
                .orElseThrow(() -> new RuntimeException("Gestión no encontrada"));

        GradoMateria entity = GradoMateria.builder()
                .grado(grado)
                .materia(materia)
                .gestion(gestion)
                .build();

        return mapper.toDTO(repository.save(entity));
    }

    @Override
    public List<GradoMateriaResponseDTO> listar() {
        return repository.findAll().stream()
                .map(mapper::toDTO)
                .toList();
    }

    @Override
    public GradoMateriaResponseDTO obtenerPorId(Long id) {
        GradoMateria entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Registro no encontrado"));
        return mapper.toDTO(entity);
    }

    @Override
    public GradoMateriaResponseDTO actualizar(Long id, GradoMateriaRequestDTO dto) {
        GradoMateria entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Registro no encontrado"));

        // Validar duplicados
        boolean existe = repository.existsByGrado_IdGradoAndMateria_IdMateriaAndGestion_IdGestion(
                dto.getIdGrado(), dto.getIdMateria(), dto.getIdGestion());

        if (existe && !entity.getIdGradoMateria().equals(id)) {
            throw new IllegalArgumentException("Ya existe esa combinación en otro registro");
        }

        Grado grado = gradoRepository.findById(dto.getIdGrado())
                .orElseThrow(() -> new RuntimeException("Grado no encontrado"));
        Materia materia = materiaRepository.findById(dto.getIdMateria())
                .orElseThrow(() -> new RuntimeException("Materia no encontrada"));
        GestionAcademica gestion = gestionRepository.findById(dto.getIdGestion())
                .orElseThrow(() -> new RuntimeException("Gestión no encontrada"));

        entity.setGrado(grado);
        entity.setMateria(materia);
        entity.setGestion(gestion);

        return mapper.toDTO(repository.save(entity));
    }

    @Override
    public void eliminar(Long id) {
        repository.deleteById(id);
    }
}
