package com.unidadeducativa.academia.asignaciondocente.model;

import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.personas.profesor.model.Profesor;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "asignacion_docente", uniqueConstraints = @UniqueConstraint(columnNames = { "id_profesor", "id_materia",
                "id_curso", "id_gestion" }))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AsignacionDocente {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id_asignacion")
        private Long idAsignacion;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "id_profesor", nullable = false)
        private Profesor profesor;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "id_materia", nullable = false)
        private Materia materia;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "id_curso", nullable = false)
        private Curso curso;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "id_gestion", nullable = false)
        private GestionAcademica gestion;

        @Column(nullable = false)
        @Builder.Default
        private Boolean estado = true;

        @Column(name = "fecha_inicio", nullable = false)
        @Builder.Default
        private LocalDate fechaInicio = LocalDate.now();

        @Column(name = "fecha_fin")
        private LocalDate fechaFin;
}
