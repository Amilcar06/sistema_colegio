package com.unidadeducativa.comunicacion.dto;

import com.unidadeducativa.comunicacion.enums.Prioridad;
import com.unidadeducativa.comunicacion.enums.TipoDestinatario;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class ComunicadoResponseDTO {
    private Long idComunicado;
    private String titulo;
    private String contenido;
    private LocalDateTime fechaPublicacion;
    private Prioridad prioridad;
    private TipoDestinatario tipoDestinatario;
    private String nombreAutor;
}
