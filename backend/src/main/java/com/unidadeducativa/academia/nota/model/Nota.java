package com.unidadeducativa.academia.nota.model;

import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.shared.enums.Trimestre;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "nota", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "id_estudiante", "id_asignacion", "trimestre" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Nota {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_nota")
    private Long idNota;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_estudiante", nullable = false)
    private Estudiante estudiante;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_asignacion", nullable = false)
    private AsignacionDocente asignacion;

    @Column(name = "ser") // nullable by default
    @Builder.Default
    private Double ser = 0.0;

    @Column(name = "saber")
    @Builder.Default
    private Double saber = 0.0;

    @Column(name = "hacer")
    @Builder.Default
    private Double hacer = 0.0;

    @Column(name = "decidir")
    @Builder.Default
    private Double decidir = 0.0;

    @Column(name = "autoevaluacion")
    @Builder.Default
    private Double autoevaluacion = 0.0;

    @Column(name = "nota_final")
    @Builder.Default
    private Double notaFinal = 0.0;

    // Deprecating 'valor' in favor of 'notaFinal' but keeping logic consistent
    // private Double valor;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Trimestre trimestre;

    @Column(name = "fecha_registro", nullable = false)
    @Builder.Default
    private LocalDate fechaRegistro = LocalDate.now();
}
