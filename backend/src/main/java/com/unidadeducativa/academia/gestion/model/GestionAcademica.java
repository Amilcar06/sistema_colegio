package com.unidadeducativa.academia.gestion.model;

import com.unidadeducativa.institucion.model.UnidadEducativa;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gestion_academica", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "anio", "id_unidad_educativa" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GestionAcademica {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_gestion")
    private Long idGestion;

    @Column(nullable = false)
    private Integer anio;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_unidad_educativa", nullable = true)
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
    private UnidadEducativa unidadEducativa;

    @Column(nullable = false)
    @Builder.Default
    private Boolean estado = true;
}
