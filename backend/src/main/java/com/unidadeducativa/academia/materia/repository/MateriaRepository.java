package com.unidadeducativa.academia.materia.repository;

import com.unidadeducativa.academia.materia.model.Materia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MateriaRepository extends JpaRepository<Materia, Long> {
    boolean existsByNombreIgnoreCase(String nombre);

    // Scoped methods
    boolean existsByNombreIgnoreCaseAndUnidadEducativa_IdUnidadEducativa(String nombre, Long idUnidadEducativa);

    List<Materia> findAllByUnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);

    @Query("SELECT DISTINCT m FROM Materia m " +
            "JOIN GradoMateria gm ON m.idMateria = gm.materia.idMateria " +
            "JOIN Curso c ON c.grado.idGrado = gm.grado.idGrado " +
            "WHERE c.idCurso = :idCurso")
    List<Materia> findByCursoIdCurso(@Param("idCurso") Long idCurso);

    java.util.List<Materia> findByNombre(String nombre);
}