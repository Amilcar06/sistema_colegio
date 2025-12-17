package com.unidadeducativa.notificaciones.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class NotificacionResponseDTO {
    private Long idNotificacion;
    private String titulo;
    private String mensaje;
    private boolean leido;
    private LocalDateTime fechaCreacion;
}
