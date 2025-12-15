package com.unidadeducativa.academia.inscripcion.dto;

import com.unidadeducativa.shared.enums.EstadoInscripcion;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InscripcionEstadoRequestDTO {

    @NotNull
    private Long idInscripcion;

    @NotNull
    private EstadoInscripcion nuevoEstado;
}
