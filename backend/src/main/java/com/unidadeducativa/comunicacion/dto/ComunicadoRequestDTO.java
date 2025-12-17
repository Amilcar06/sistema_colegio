package com.unidadeducativa.comunicacion.dto;

import com.unidadeducativa.comunicacion.enums.Prioridad;
import com.unidadeducativa.comunicacion.enums.TipoDestinatario;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ComunicadoRequestDTO {
    @NotBlank
    private String titulo;

    @NotBlank
    private String contenido;

    @NotNull
    private Prioridad prioridad;

    @NotNull
    private TipoDestinatario tipoDestinatario;

    // Optional: Only if targeting a specific course
    private Long idReferencia;
}
