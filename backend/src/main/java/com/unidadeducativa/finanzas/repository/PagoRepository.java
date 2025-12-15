package com.unidadeducativa.finanzas.repository;

import com.unidadeducativa.finanzas.model.Pago;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PagoRepository extends JpaRepository<Pago, Long> {
    List<Pago> findByCuentaCobrar_IdCuentaCobrar(Long idCuentaCobrar);

    List<Pago> findByCuentaCobrar_Estudiante_IdEstudiante(Long idEstudiante);

    List<Pago> findByCuentaCobrar_TipoPago_UnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);

    List<Pago> findByFechaPagoBetweenAndCuentaCobrar_TipoPago_UnidadEducativa_IdUnidadEducativa(LocalDateTime inicio,
            LocalDateTime fin, Long idUnidadEducativa);
}
