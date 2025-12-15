package com.unidadeducativa.academia.nota.dto;

import com.unidadeducativa.shared.enums.Trimestre;
import jakarta.validation.constraints.*;

import lombok.Getter;
import lombok.Setter;
@Getter
@Setter
public class NotaRequestDTO {
    @NotNull
    private Long idEstudiante;
    @NotNull
    private Long idAsignacion;
    @NotNull
    @DecimalMin(value = "0.0")
    @DecimalMax(value = "100.0")
    private Double valor;
    @NotNull
    private Trimestre trimestre;
}
