package com.unidadeducativa.academia.curso.dto;

import com.unidadeducativa.shared.enums.TipoTurno;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CursoUpdateDTO {

    @NotNull(message = "El id del grado es obligatorio")
    private Long idGrado;

    @NotNull(message = "El paralelo es obligatorio")
    @Size(min = 1, max = 1, message = "El paralelo debe ser un solo carácter")
    private String paralelo;

    @NotNull(message = "El turno es obligatorio")
    private TipoTurno turno;
}
