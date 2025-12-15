package com.unidadeducativa.academia.asignaciondocente.repository;

import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AsignacionDocenteRepository extends JpaRepository<AsignacionDocente, Long> {
    boolean existsByProfesorIdProfesorAndMateriaIdMateriaAndCursoIdCursoAndGestionIdGestion(
            Long idProfesor, Long idMateria, Long idCurso, Long idGestion);

    java.util.Optional<AsignacionDocente> findByProfesorAndCursoAndMateria(
            com.unidadeducativa.personas.profesor.model.Profesor profesor,
            com.unidadeducativa.academia.curso.model.Curso curso,
            com.unidadeducativa.academia.materia.model.Materia materia);
}
