package com.unidadeducativa.academia.gradomateria.model;

import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "grado_materia", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"id_grado", "id_materia", "id_gestion"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GradoMateria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_grado_materia")
    private Long idGradoMateria;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_grado")
    private Grado grado;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_materia")
    private Materia materia;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_gestion")
    private GestionAcademica gestion;
}