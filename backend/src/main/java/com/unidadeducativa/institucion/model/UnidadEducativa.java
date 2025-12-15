package com.unidadeducativa.institucion.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "unidad_educativa")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UnidadEducativa {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_unidad_educativa")
    private Long idUnidadEducativa;

    @Column(nullable = false, length = 150)
    private String nombre;

    @Column(nullable = false, unique = true, length = 20)
    private String sie; // Código SIE único

    @Column(length = 255)
    private String direccion;

    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @Column(nullable = false)
    @Builder.Default
    private Boolean estado = true; // Activo/Inactivo
}
