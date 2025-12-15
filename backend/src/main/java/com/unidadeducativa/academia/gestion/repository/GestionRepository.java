package com.unidadeducativa.academia.gestion.repository;

import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface GestionRepository extends JpaRepository<GestionAcademica, Long> {
    Optional<GestionAcademica> findByAnio(int anio);

    boolean existsByAnio(Integer anio);

    Optional<GestionAcademica> findByEstadoTrue();

    // Scoped methods
    Optional<GestionAcademica> findByAnioAndUnidadEducativa_IdUnidadEducativa(Integer anio, Long idUnidadEducativa);

    boolean existsByAnioAndUnidadEducativa_IdUnidadEducativa(Integer anio, Long idUnidadEducativa);

    Optional<GestionAcademica> findByEstadoTrueAndUnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);
}
