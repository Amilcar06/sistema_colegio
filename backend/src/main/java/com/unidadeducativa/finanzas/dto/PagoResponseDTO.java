package com.unidadeducativa.finanzas.dto;

import com.unidadeducativa.shared.enums.MetodoPago;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PagoResponseDTO {
    private Long idPago;
    private Long idCuentaCobrar;
    private BigDecimal montoPagado;
    private LocalDateTime fechaPago;
    private MetodoPago metodoPago;
    private String numeroRecibo;
    private String observaciones;
    private String nombreCajero;
    private String concepto; // Added to show what was paid
}
