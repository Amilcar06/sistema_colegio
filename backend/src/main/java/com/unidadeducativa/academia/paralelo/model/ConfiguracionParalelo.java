package com.unidadeducativa.academia.paralelo.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "configuracion_paralelo")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConfiguracionParalelo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 5)
    private String nombre; // A, B, C

    @Column(nullable = false)
    private Boolean activo;

    @Column(nullable = false)
    private Integer orden;
}
