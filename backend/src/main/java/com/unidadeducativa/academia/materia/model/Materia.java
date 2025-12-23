package com.unidadeducativa.academia.materia.model;

import com.unidadeducativa.institucion.model.UnidadEducativa;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "materia")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Materia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_materia")
    private Long idMateria;

    @Column(nullable = false, length = 100)
    private String nombre;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_unidad_educativa", nullable = true)
    private UnidadEducativa unidadEducativa;
}