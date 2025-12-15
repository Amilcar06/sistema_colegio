package com.unidadeducativa.academia.asignaciondocente.service.impl;

import com.unidadeducativa.academia.asignaciondocente.dto.AsignacionDocenteRequestDTO;
import com.unidadeducativa.academia.asignaciondocente.dto.AsignacionDocenteResponseDTO;
import com.unidadeducativa.academia.asignaciondocente.mapper.AsignacionDocenteMapper;
import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.academia.asignaciondocente.repository.AsignacionDocenteRepository;
import com.unidadeducativa.academia.asignaciondocente.service.IAsignacionDocenteService;
import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.curso.repository.CursoRepository;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.gestion.repository.GestionRepository;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.materia.repository.MateriaRepository;
import com.unidadeducativa.personas.profesor.model.Profesor;
import com.unidadeducativa.personas.profesor.repository.ProfesorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AsignacionDocenteServiceImpl implements IAsignacionDocenteService {

        private final AsignacionDocenteRepository repository;
        private final ProfesorRepository profesorRepository;
        private final MateriaRepository materiaRepository;
        private final CursoRepository cursoRepository;
        private final GestionRepository gestionRepository;
        private final AsignacionDocenteMapper mapper;

        @Override
        public AsignacionDocenteResponseDTO crear(AsignacionDocenteRequestDTO dto) {
                if (repository.existsByProfesorIdProfesorAndMateriaIdMateriaAndCursoIdCursoAndGestionIdGestion(
                                dto.getIdProfesor(), dto.getIdMateria(), dto.getIdCurso(), dto.getIdGestion())) {
                        throw new IllegalArgumentException("Ya existe una asignación con estos datos");
                }

                Profesor profesor = profesorRepository.findById(dto.getIdProfesor())
                                .orElseThrow(() -> new RuntimeException("Profesor no encontrado"));

                Materia materia = materiaRepository.findById(dto.getIdMateria())
                                .orElseThrow(() -> new RuntimeException("Materia no encontrada"));

                Curso curso = cursoRepository.findById(dto.getIdCurso())
                                .orElseThrow(() -> new RuntimeException("Curso no encontrado"));

                GestionAcademica gestion = gestionRepository.findById(dto.getIdGestion())
                                .orElseThrow(() -> new RuntimeException("Gestión no encontrada"));

                AsignacionDocente asignacion = AsignacionDocente.builder()
                                .profesor(profesor)
                                .materia(materia)
                                .curso(curso)
                                .gestion(gestion)
                                .estado(dto.getEstado() != null ? dto.getEstado() : true)
                                .fechaInicio(dto.getFechaInicio() != null ? dto.getFechaInicio()
                                                : java.time.LocalDate.now())
                                .fechaFin(dto.getFechaFin())
                                .build();

                return mapper.toDTO(repository.save(asignacion));
        }

        @Override
        public AsignacionDocenteResponseDTO actualizar(Long id, AsignacionDocenteRequestDTO dto) {
                AsignacionDocente asignacion = repository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Asignación no encontrada"));

                Profesor profesor = profesorRepository.findById(dto.getIdProfesor())
                                .orElseThrow(() -> new RuntimeException("Profesor no encontrado"));
                Materia materia = materiaRepository.findById(dto.getIdMateria())
                                .orElseThrow(() -> new RuntimeException("Materia no encontrada"));
                Curso curso = cursoRepository.findById(dto.getIdCurso())
                                .orElseThrow(() -> new RuntimeException("Curso no encontrado"));
                GestionAcademica gestion = gestionRepository.findById(dto.getIdGestion())
                                .orElseThrow(() -> new RuntimeException("Gestión no encontrada"));

                asignacion.setProfesor(profesor);
                asignacion.setMateria(materia);
                asignacion.setCurso(curso);
                asignacion.setGestion(gestion);
                asignacion.setEstado(dto.getEstado());
                asignacion.setFechaInicio(dto.getFechaInicio());
                asignacion.setFechaFin(dto.getFechaFin());

                return mapper.toDTO(repository.save(asignacion));
        }

        @Override
        public void eliminar(Long id) {
                repository.deleteById(id);
        }

        @Override
        public List<AsignacionDocenteResponseDTO> listarPorCurso(Long idCurso) {
                return repository.findAll().stream()
                                .filter(a -> a.getCurso().getIdCurso().equals(idCurso))
                                .map(mapper::toDTO)
                                .collect(Collectors.toList());
        }

        @Override
        public List<AsignacionDocenteResponseDTO> listarPorProfesor(Long idProfesor) {
                return repository.findAll().stream()
                                .filter(a -> a.getProfesor().getIdProfesor().equals(idProfesor))
                                .map(mapper::toDTO)
                                .collect(Collectors.toList());
        }

        @Override
        public List<AsignacionDocenteResponseDTO> listarMateriasAsignadasPorCurso(Long idCurso) {
                return repository.findAll().stream()
                                .filter(a -> a.getCurso().getIdCurso().equals(idCurso))
                                .map(mapper::toDTO)
                                .collect(Collectors.toList());
        }

        @Override
        public List<AsignacionDocenteResponseDTO> listarPorUsuario(String correo) {
                Profesor profesor = profesorRepository.findByUsuario_Correo(correo)
                                .orElseThrow(() -> new RuntimeException("Profesor no encontrado para este usuario"));

                return listarPorProfesor(profesor.getIdProfesor());
        }
}
