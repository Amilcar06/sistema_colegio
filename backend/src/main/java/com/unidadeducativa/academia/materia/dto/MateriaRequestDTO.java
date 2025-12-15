package com.unidadeducativa.academia.materia.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MateriaRequestDTO {
    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;
}
