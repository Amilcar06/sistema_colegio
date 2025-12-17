package com.unidadeducativa.comunicacion.model;

import com.unidadeducativa.comunicacion.enums.Prioridad;
import com.unidadeducativa.comunicacion.enums.TipoDestinatario;
import com.unidadeducativa.usuario.model.Usuario;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "comunicado")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Comunicado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_comunicado")
    private Long idComunicado;

    @Column(nullable = false)
    private String titulo;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String contenido;

    @Column(name = "fecha_publicacion", nullable = false)
    private LocalDateTime fechaPublicacion;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Prioridad prioridad;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_destinatario", nullable = false)
    private TipoDestinatario tipoDestinatario;

    /**
     * ID de referencia opcional.
     * Si tipoDestinatario == POR_CURSO, idReferencia = idCurso
     * Si tipoDestinatario == POR_ROL, idReferencia could be ID of Rol (if needed,
     * or logic in Service)
     */
    @Column(name = "id_referencia")
    private Long idReferencia;

    @ManyToOne
    @JoinColumn(name = "id_autor", nullable = false)
    private Usuario autor;

    @PrePersist
    protected void onCreate() {
        if (this.fechaPublicacion == null) {
            this.fechaPublicacion = LocalDateTime.now();
        }
    }
}
