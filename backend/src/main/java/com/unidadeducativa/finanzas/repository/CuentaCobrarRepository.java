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

    // Buscar morosos: Cuentas pendientes de estudiantes de una Unidad Educativa
    @org.springframework.data.jpa.repository.Query("SELECT cc FROM CuentaCobrar cc WHERE cc.estado = :estado AND cc.estudiante.usuario.unidadEducativa.idUnidadEducativa = :idUnidadEducativa")
    List<CuentaCobrar> findByEstadoAndEstudianteUsuarioUnidadEducativaIdUnidadEducativa(
            @org.springframework.data.repository.query.Param("estado") EstadoPago estado,
            @org.springframework.data.repository.query.Param("idUnidadEducativa") Long idUnidadEducativa);
}
