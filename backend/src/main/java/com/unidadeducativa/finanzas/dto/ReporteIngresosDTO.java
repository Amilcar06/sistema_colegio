package com.unidadeducativa.finanzas.dto;

import com.unidadeducativa.shared.enums.MetodoPago;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Map;

@Data
@Builder
public class ReporteIngresosDTO {
    private BigDecimal totalRecaudado;
    private Long cantidadTransacciones;
    private Map<MetodoPago, BigDecimal> porMetodoPago;
}
