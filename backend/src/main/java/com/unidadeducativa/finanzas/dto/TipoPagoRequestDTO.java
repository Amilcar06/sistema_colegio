package com.unidadeducativa.finanzas.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
public class TipoPagoRequestDTO {
    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @NotNull(message = "El monto es obligatorio")
    @DecimalMin(value = "0.00", message = "El monto no puede ser negativo")
    private BigDecimal montoDefecto;

    private LocalDate fechaLimite;
    private Long idGestion;
}
