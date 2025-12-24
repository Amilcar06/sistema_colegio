package com.unidadeducativa.finanzas.dto;

import com.unidadeducativa.shared.enums.EstadoPago;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
public class ItemEstadoCuentaDTO {
    private Long idCuentaCobrar;
    private String concepto; // Nombre del TipoPago
    private BigDecimal monto;
    private BigDecimal saldoPendiente;
    private EstadoPago estado;
    private LocalDate fechaVencimiento;
    private Integer diasRetraso;
    private boolean esMensualidad; // Helper flag
}
