package com.unidadeducativa.academia.inscripcion.model;

import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.inscripcionmateria.model.InscripcionMateria;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.shared.enums.EstadoInscripcion;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "inscripcion", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "id_estudiante", "id_gestion" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Inscripcion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_inscripcion")
    private Long idInscripcion;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_estudiante", nullable = false)
    private Estudiante estudiante;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_curso", nullable = false)
    private Curso curso;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_gestion", nullable = false)
    private GestionAcademica gestion;

    @NotNull
    @Column(name = "fecha_inscripcion", nullable = false)
    @Builder.Default
    private LocalDate fechaInscripcion = LocalDate.now();

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private EstadoInscripcion estado = EstadoInscripcion.ACTIVO;

    @OneToMany(mappedBy = "inscripcion", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<InscripcionMateria> materiasAsignadas;
}
