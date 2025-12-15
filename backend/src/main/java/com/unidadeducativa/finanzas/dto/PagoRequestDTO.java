package com.unidadeducativa.finanzas.dto;

import com.unidadeducativa.shared.enums.MetodoPago;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PagoRequestDTO {
    @NotNull(message = "El ID de la cuenta por cobrar es obligatorio")
    private Long idCuentaCobrar;

    @NotNull(message = "El monto pagado es obligatorio")
    @DecimalMin(value = "0.01", message = "El monto debe ser mayor a 0")
    private BigDecimal montoPagado;

    @NotNull(message = "El método de pago es obligatorio")
    private MetodoPago metodoPago;

    private String observaciones;
}
