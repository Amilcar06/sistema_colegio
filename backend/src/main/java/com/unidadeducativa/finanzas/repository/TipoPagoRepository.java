package com.unidadeducativa.finanzas.repository;

import com.unidadeducativa.finanzas.model.TipoPago;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TipoPagoRepository extends JpaRepository<TipoPago, Long> {
    List<TipoPago> findAllByUnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);

    List<TipoPago> findAllByUnidadEducativa_IdUnidadEducativaAndGestion_IdGestion(Long idUnidadEducativa,
            Long idGestion);

    java.util.Optional<TipoPago> findByNombre(String nombre);
}
