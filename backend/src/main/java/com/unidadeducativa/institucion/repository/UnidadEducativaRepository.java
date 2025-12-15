package com.unidadeducativa.institucion.repository;

import com.unidadeducativa.institucion.model.UnidadEducativa;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UnidadEducativaRepository extends JpaRepository<UnidadEducativa, Long> {
    Optional<UnidadEducativa> findBySie(String sie);

    boolean existsBySie(String sie);
}
