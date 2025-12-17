package com.unidadeducativa.comunicacion.dto;

import com.unidadeducativa.comunicacion.enums.TipoEvento;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class EventoRequestDTO {
    @NotBlank
    private String titulo;

    private String descripcion;

    @NotNull
    private LocalDateTime fechaInicio;

    @NotNull
    private LocalDateTime fechaFin;

    private String ubicacion;

    @NotNull
    private TipoEvento tipoEvento;
}
