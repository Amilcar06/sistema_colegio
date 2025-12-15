package com.unidadeducativa.finanzas.repository;

import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.shared.enums.EstadoPago;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CuentaCobrarRepository extends JpaRepository<CuentaCobrar, Long> {
    List<CuentaCobrar> findByEstudiante_IdEstudiante(Long idEstudiante);

    List<CuentaCobrar> findByTipoPago_UnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);

    List<CuentaCobrar> findByEstudiante_IdEstudianteAndEstado(Long idEstudiante, EstadoPago estado);

    boolean existsByTipoPago_IdTipoPago(Long idTipoPago);

    boolean existsByEstudianteAndTipoPago(com.unidadeducativa.personas.estudiante.model.Estudiante estudiante,
            com.unidadeducativa.finanzas.model.TipoPago tipoPago);
}
