package com.unidadeducativa.academia.gestion.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GestionUpdateDTO {
    @NotNull(message = "El año de la gestión es obligatorio")
    @Min(value = 2000, message = "El año debe ser mayor a 2000")
    @Max(value = 2100, message = "El año debe ser menor a 2100")
    private Integer anio;

    @NotNull(message = "El estado es obligatorio")
    private Boolean estado;
}