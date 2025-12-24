package com.unidadeducativa.academia.inscripcion.service.impl;

import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.curso.repository.CursoRepository;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.gestion.repository.GestionRepository;
import com.unidadeducativa.academia.inscripcion.dto.*;
import com.unidadeducativa.academia.inscripcion.mapper.InscripcionMapper;
import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;
import com.unidadeducativa.academia.inscripcion.service.IInscripcionService;
import com.unidadeducativa.academia.inscripcionmateria.model.InscripcionMateria;
import com.unidadeducativa.academia.inscripcionmateria.repository.InscripcionMateriaRepository;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.materia.repository.MateriaRepository;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.shared.enums.EstadoInscripcion;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InscripcionServiceImpl implements IInscripcionService {

        private final InscripcionRepository inscripcionRepository;
        private final EstudianteRepository estudianteRepository;
        private final CursoRepository cursoRepository;
        private final GestionRepository gestionRepository;
        private final MateriaRepository materiaRepository;
        private final InscripcionMateriaRepository inscripcionMateriaRepository;
        private final InscripcionMapper inscripcionMapper;

        @Override
        @Transactional
        public InscripcionResponseDTO registrar(InscripcionRequestDTO dto) {
                Estudiante estudiante = estudianteRepository.findById(dto.getIdEstudiante())
                                .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));

                Curso curso = cursoRepository.findById(dto.getIdCurso())
                                .orElseThrow(() -> new RuntimeException("Curso no encontrado"));

                GestionAcademica gestion = gestionRepository.findByEstadoTrue()
                                .orElseThrow(() -> new RuntimeException("No hay gestión académica activa"));

                // Validación: inscripción duplicada
                boolean yaExiste = inscripcionRepository
                                .existsByEstudianteIdEstudianteAndCursoIdCursoAndGestionIdGestion(
                                                estudiante.getIdEstudiante(), curso.getIdCurso(),
                                                gestion.getIdGestion());
                if (yaExiste) {
                        throw new RuntimeException(
                                        "El estudiante ya está inscrito en este curso para la gestión activa");
                }

                // Crear inscripción
                Inscripcion inscripcion = Inscripcion.builder()
                                .estudiante(estudiante)
                                .curso(curso)
                                .gestion(gestion)
                                .fechaInscripcion(LocalDate.now())
                                .estado(EstadoInscripcion.ACTIVO)
                                .build();

                Inscripcion guardada = inscripcionRepository.save(inscripcion);

                // Asignar materias del curso automáticamente
                List<Materia> materias = materiaRepository.findByCursoIdCurso(curso.getIdCurso());

                List<InscripcionMateria> inscripcionesMateria = materias.stream()
                                .map(materia -> InscripcionMateria.builder()
                                                .inscripcion(guardada)
                                                .materia(materia)
                                                .build())
                                .toList();

                inscripcionMateriaRepository.saveAll(inscripcionesMateria);

                return inscripcionMapper.toDTO(guardada);
        }

        @Override
        public List<InscripcionResponseDTO> listar() {
                return inscripcionRepository.findAll().stream()
                                .map(inscripcionMapper::toDTO)
                                .toList();
        }

        @Override
        public List<InscripcionResponseDTO> listarPorEstudiante(Long idEstudiante) {
                return inscripcionRepository.findByEstudianteIdEstudiante(idEstudiante).stream()
                                .map(inscripcionMapper::toDTO)
                                .toList();
        }

        @Override
        public Page<InscripcionResponseDTO> listarPorCurso(Long idCurso, Pageable pageable) {
                return inscripcionRepository.findByCursoIdCurso(idCurso, pageable)
                                .map(inscripcionMapper::toDTO);
        }

        @Override
        public Page<InscripcionResponseDTO> listarPorGestion(Long idGestion, Pageable pageable) {
                return inscripcionRepository.findByGestionIdGestion(idGestion, pageable)
                                .map(inscripcionMapper::toDTO);
        }

        @Override
        public List<InscripcionResponseDTO> listarPorCursoYGestion(Long idCurso, Long idGestion) {
                return inscripcionRepository.findByCursoIdCursoAndGestionIdGestion(idCurso, idGestion).stream()
                                .map(inscripcionMapper::toDTO)
                                .toList();
        }

        @Override
        public void cambiarEstadoInscripcion(InscripcionEstadoRequestDTO dto) {
                Inscripcion inscripcion = inscripcionRepository.findById(dto.getIdInscripcion())
                                .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

                inscripcion.setEstado(dto.getNuevoEstado());
                inscripcionRepository.save(inscripcion);
        }

        @Override
        public List<InscripcionResponseDTO> listarEstudiantesPorCurso(Long idCurso) {
                // Básicamente es lo mismo que listarPorCurso (por diseño)
                return inscripcionRepository.findByCursoIdCurso(idCurso).stream()
                                .map(inscripcionMapper::toDTO)
                                .toList();
        }
}
