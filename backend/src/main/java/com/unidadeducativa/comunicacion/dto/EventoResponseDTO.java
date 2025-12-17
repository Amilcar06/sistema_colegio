package com.unidadeducativa.comunicacion.dto;

import com.unidadeducativa.comunicacion.enums.TipoEvento;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class EventoResponseDTO {
    private Long idEvento;
    private String titulo;
    private String descripcion;
    private LocalDateTime fechaInicio;
    private LocalDateTime fechaFin;
    private String ubicacion;
    private TipoEvento tipoEvento;
}
