package com.unidadeducativa.finanzas.dto;

import com.unidadeducativa.shared.enums.EstadoPago;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuentaCobrarResponseDTO {
    private Long idCuentaCobrar;
    private String nombreTipoPago;
    private BigDecimal montoTotal;
    private BigDecimal saldoPendiente;
    private EstadoPago estado;
    private LocalDate fechaVencimiento;
    private String nombreEstudiante;
}
