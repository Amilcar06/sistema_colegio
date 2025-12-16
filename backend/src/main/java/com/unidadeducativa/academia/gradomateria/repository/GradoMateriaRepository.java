package com.unidadeducativa.academia.gradomateria.repository;

import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.academia.gradomateria.model.GradoMateria;
import com.unidadeducativa.academia.materia.model.Materia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface GradoMateriaRepository extends JpaRepository<GradoMateria, Long> {
    boolean existsByGrado_IdGradoAndMateria_IdMateriaAndGestion_IdGestion(Long idGrado, Long idMateria, Long idGestion);

    boolean existsByGradoAndMateriaAndGestion(Grado grado, Materia materia, GestionAcademica gestion);

    List<GradoMateria> findByMateria_IdMateria(Long idMateria);

    List<GradoMateria> findByGradoIdGrado(Long idGrado);

    @Query("SELECT gm.materia FROM GradoMateria gm WHERE gm.grado.idGrado = :idGrado")
    List<Materia> findMateriasByGrado_IdGrado(@Param("idGrado") Long idGrado);

    List<GradoMateria> findByGradoAndGestion(Grado grado, GestionAcademica gestion);
}
