package com.unidadeducativa.academia.inscripcionmateria.repository;

import com.unidadeducativa.academia.inscripcionmateria.model.InscripcionMateria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InscripcionMateriaRepository extends JpaRepository<InscripcionMateria, Long> {
    List<InscripcionMateria> findByInscripcion_IdInscripcion(Long idInscripcion);

    List<InscripcionMateria> findByMateria_IdMateria(Long idMateria);

    boolean existsByInscripcion_IdInscripcionAndMateria_IdMateria(Long idInscripcion, Long idMateria);
}
