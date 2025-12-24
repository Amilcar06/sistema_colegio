package com.unidadeducativa.academia.inscripcion.repository;

import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface InscripcionRepository extends JpaRepository<Inscripcion, Long> {

        List<Inscripcion> findByEstudianteIdEstudiante(Long idEstudiante);

        org.springframework.data.domain.Page<Inscripcion> findByGestionIdGestion(Long idGestion,
                        org.springframework.data.domain.Pageable pageable);

        List<Inscripcion> findByGestionIdGestion(Long idGestion);

        org.springframework.data.domain.Page<Inscripcion> findByCursoIdCurso(Long idCurso,
                        org.springframework.data.domain.Pageable pageable);

        List<Inscripcion> findByCursoIdCurso(Long idCurso);

        List<Inscripcion> findByCursoIdCursoAndGestionIdGestion(Long idCurso, Long idGestion);

        Optional<Inscripcion> findByEstudianteAndGestionEstadoTrue(Estudiante estudiante);

        // Este es el método que usa tu service:
        // Este es el método que usa tu service:
        boolean existsByEstudianteIdEstudianteAndCursoIdCursoAndGestionIdGestion(Long idEstudiante, Long idCurso,
                        Long idGestion);

        Optional<Inscripcion> findByEstudianteAndGestion(Estudiante estudiante,
                        com.unidadeducativa.academia.gestion.model.GestionAcademica gestion);

        List<Inscripcion> findByCursoIdCursoAndEstado(Long idCurso,
                        com.unidadeducativa.shared.enums.EstadoInscripcion estado);

        List<Inscripcion> findByGestionAndEstado(com.unidadeducativa.academia.gestion.model.GestionAcademica gestion,
                        com.unidadeducativa.shared.enums.EstadoInscripcion estado);
}
