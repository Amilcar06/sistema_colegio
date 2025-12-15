package com.unidadeducativa.academia.curso.model;

import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.shared.enums.TipoTurno;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "curso", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"id_grado", "paralelo", "turno"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Curso {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_curso")
    private Long idCurso;

    @ManyToOne
    @JoinColumn(name = "id_grado", nullable = false)
    private Grado grado;

    @Column(nullable = false, length = 1)
    private String paralelo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoTurno turno;
}
