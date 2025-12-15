package com.unidadeducativa.academia.inscripcionmateria.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InscripcionMateriaRequestDTO {

    @NotNull(message = "El ID de la inscripción es obligatorio.")
    private Long idInscripcion;

    @NotNull(message = "El ID de la materia es obligatorio.")
    private Long idMateria;
}
