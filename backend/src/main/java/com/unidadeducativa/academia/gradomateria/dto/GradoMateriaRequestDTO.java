package com.unidadeducativa.academia.gradomateria.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GradoMateriaRequestDTO {
    @NotNull(message = "El id del grado es obligatorio")
    private Long idGrado;

    @NotNull(message = "El id de la materia es obligatorio")
    private Long idMateria;

    @NotNull(message = "El id de la gestión es obligatorio")
    private Long idGestion;
}
