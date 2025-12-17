package com.unidadeducativa.comunicacion.model;

import com.unidadeducativa.comunicacion.enums.TipoEvento;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "evento")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Evento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_evento")
    private Long idEvento;

    @Column(nullable = false)
    private String titulo;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "fecha_inicio", nullable = false)
    private LocalDateTime fechaInicio;

    @Column(name = "fecha_fin", nullable = false)
    private LocalDateTime fechaFin;

    private String ubicacion;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_evento", nullable = false)
    private TipoEvento tipoEvento;
}
