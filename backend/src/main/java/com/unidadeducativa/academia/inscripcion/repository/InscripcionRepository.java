package com.unidadeducativa.academia.inscripcion.repository;

import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface InscripcionRepository extends JpaRepository<Inscripcion, Long> {

    List<Inscripcion> findByEstudianteIdEstudiante(Long idEstudiante);

    List<Inscripcion> findByCursoIdCurso(Long idCurso);

    List<Inscripcion> findByGestionIdGestion(Long idGestion);

    List<Inscripcion> findByCursoIdCursoAndGestionIdGestion(Long idCurso, Long idGestion);

    Optional<Inscripcion> findByEstudianteAndGestionEstadoTrue(Estudiante estudiante);

    // Este es el método que usa tu service:
    // Este es el método que usa tu service:
    boolean existsByEstudianteIdEstudianteAndCursoIdCursoAndGestionIdGestion(Long idEstudiante, Long idCurso,
            Long idGestion);

    Optional<Inscripcion> findByEstudianteAndGestion(Estudiante estudiante,
            com.unidadeducativa.academia.gestion.model.GestionAcademica gestion);
}
