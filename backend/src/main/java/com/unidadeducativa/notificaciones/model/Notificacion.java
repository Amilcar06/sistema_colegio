package com.unidadeducativa.notificaciones.model;

import com.unidadeducativa.usuario.model.Usuario;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notificacion")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notificacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idNotificacion;

    @Column(nullable = false)
    private String titulo;

    @Column(columnDefinition = "TEXT")
    private String mensaje;

    private boolean leido;

    @Builder.Default
    private LocalDateTime fechaCreacion = LocalDateTime.now();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario")
    private Usuario usuario; // Destinatario
}
