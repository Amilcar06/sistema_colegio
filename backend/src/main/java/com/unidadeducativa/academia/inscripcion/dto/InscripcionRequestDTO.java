package com.unidadeducativa.academia.inscripcion.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class InscripcionRequestDTO {

    @NotNull(message = "El ID del estudiante es obligatorio.")
    private Long idEstudiante;

    @NotNull(message = "El ID del curso es obligatorio.")
    private Long idCurso;
}