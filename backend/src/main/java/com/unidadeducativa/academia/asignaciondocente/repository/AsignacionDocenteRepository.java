package com.unidadeducativa.academia.asignaciondocente.repository;

import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AsignacionDocenteRepository extends JpaRepository<AsignacionDocente, Long> {
        boolean existsByProfesorIdProfesorAndMateriaIdMateriaAndCursoIdCursoAndGestionIdGestion(
                        Long idProfesor, Long idMateria, Long idCurso, Long idGestion);

        List<AsignacionDocente> findByMateria_IdMateria(Long idMateria);

        boolean existsByMateria_IdMateriaAndCurso_IdCursoAndGestion_IdGestion(Long idMateria, Long idCurso,
                        Long idGestion);

        java.util.Optional<AsignacionDocente> findByProfesorAndCursoAndMateria(
                        com.unidadeducativa.personas.profesor.model.Profesor profesor,
                        com.unidadeducativa.academia.curso.model.Curso curso,
                        com.unidadeducativa.academia.materia.model.Materia materia);
}
