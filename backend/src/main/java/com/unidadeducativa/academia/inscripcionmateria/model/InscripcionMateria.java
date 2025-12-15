package com.unidadeducativa.academia.inscripcionmateria.model;

import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.materia.model.Materia;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "inscripcion_materia", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"id_inscripcion", "id_materia"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InscripcionMateria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_inscripcion_materia")
    private Long idInscripcionMateria;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_inscripcion", nullable = false)
    private Inscripcion inscripcion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_materia", nullable = false)
    private Materia materia;
}
