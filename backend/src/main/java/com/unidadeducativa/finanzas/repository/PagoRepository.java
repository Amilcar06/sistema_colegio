package com.unidadeducativa.finanzas.repository;

import com.unidadeducativa.finanzas.model.Pago;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PagoRepository extends JpaRepository<Pago, Long> {
        List<Pago> findByCuentaCobrar_IdCuentaCobrar(Long idCuentaCobrar);

        List<Pago> findByCuentaCobrar_Estudiante_IdEstudiante(Long idEstudiante);

        List<Pago> findByCuentaCobrar_TipoPago_UnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);

        List<Pago> findByFechaPagoBetweenAndCuentaCobrar_TipoPago_UnidadEducativa_IdUnidadEducativa(
                        LocalDateTime inicio,
                        LocalDateTime fin, Long idUnidadEducativa);

        // Suma de pagos agrupada por día para una Unidad Educativa en un rango de
        // fechas
        @Query(value = "SELECT DATE(p.fecha_pago) as fecha, SUM(p.monto_pagado) as total " +
                        "FROM pago p " +
                        "JOIN cuenta_cobrar cc ON p.id_cuenta_cobrar = cc.id_cuenta_cobrar " +
                        "JOIN estudiante e ON cc.id_estudiante = e.id_estudiante " +
                        "JOIN usuario u ON e.id_usuario = u.id_usuario " +
                        "WHERE u.id_unidad_educativa = :idUnidadEducativa " +
                        "AND p.fecha_pago BETWEEN :fechaInicio AND :fechaFin " +
                        "GROUP BY DATE(p.fecha_pago) " +
                        "ORDER BY DATE(p.fecha_pago) ASC", nativeQuery = true)
        List<Object[]> findIngresosPorDia(
                        @Param("idUnidadEducativa") Long idUnidadEducativa,
                        @Param("fechaInicio") LocalDateTime fechaInicio,
                        @Param("fechaFin") LocalDateTime fechaFin);

        // Ultimas 20 transacciones
        @Query("SELECT p FROM Pago p WHERE p.cuentaCobrar.tipoPago.unidadEducativa.idUnidadEducativa = :idUnidadEducativa ORDER BY p.fechaPago DESC")
        List<Pago> findUltimasTransacciones(@Param("idUnidadEducativa") Long idUnidadEducativa, Pageable pageable);
}
