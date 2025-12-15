package com.unidadeducativa.academia.inscripcionmateria.service.impl;

import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;
import com.unidadeducativa.academia.inscripcionmateria.dto.InscripcionMateriaResponseDTO;
import com.unidadeducativa.academia.inscripcionmateria.mapper.InscripcionMateriaMapper;
import com.unidadeducativa.academia.inscripcionmateria.model.InscripcionMateria;
import com.unidadeducativa.academia.inscripcionmateria.repository.InscripcionMateriaRepository;
import com.unidadeducativa.academia.inscripcionmateria.service.IInscripcionMateriaService;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.gradomateria.repository.GradoMateriaRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InscripcionMateriaServiceImpl implements IInscripcionMateriaService {

    private final InscripcionRepository inscripcionRepository;
    private final GradoMateriaRepository gradoMateriaRepository;
    private final InscripcionMateriaRepository inscripcionMateriaRepository;
    private final InscripcionMateriaMapper mapper;

    @Override
    public List<InscripcionMateriaResponseDTO> listarPorInscripcion(Long idInscripcion) {
        return inscripcionMateriaRepository.findByInscripcion_IdInscripcion(idInscripcion)
                .stream().map(mapper::toDTO).toList();
    }

    @Override
    @Transactional
    public void asignarMateriasPorGrado(Long idInscripcion) {
        Inscripcion inscripcion = inscripcionRepository.findById(idInscripcion)
                .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

        Curso curso = inscripcion.getCurso();
        Long idGrado = curso.getGrado().getIdGrado();  // Asegúrate que Curso tenga relación a Grado

        List<Materia> materias = gradoMateriaRepository.findMateriasByGrado_IdGrado(idGrado);

        for (Materia materia : materias) {
            boolean yaExiste = inscripcionMateriaRepository.existsByInscripcion_IdInscripcionAndMateria_IdMateria(
                    inscripcion.getIdInscripcion(), materia.getIdMateria()
            );
            if (!yaExiste) {
                InscripcionMateria inscripcionMateria = InscripcionMateria.builder()
                        .inscripcion(inscripcion)
                        .materia(materia)
                        .build();
                inscripcionMateriaRepository.save(inscripcionMateria);
            }
        }
    }
}
