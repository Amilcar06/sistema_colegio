package com.unidadeducativa.personas.estudiante.model;

import com.unidadeducativa.usuario.model.Usuario;
import jakarta.persistence.*;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

@Entity
@Table(name = "estudiante")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Estudiante {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_estudiante")
    private Long idEstudiante;

    @Column(name = "codigo_rude", length = 50, unique = true)
    private String codigoRude;

    @Column(length = 50)
    private String direccion;

    @Column(name = "nombre_madre", length = 50)
    private String nombreMadre;

    @Column(name = "telefono_madre", length = 50)
    @Pattern(regexp = "^[0-9]+$", message = "Solo se permiten dígitos")
    @Size(min = 7, message = "Debe tener al menos 7 dígitos")
    private String telefonoMadre;

    @Column(name = "nombre_padre", length = 50)
    private String nombrePadre;

    @Column(name = "telefono_padre", length = 50)
    @Pattern(regexp = "^[0-9]+$", message = "Solo se permiten dígitos")
    @Size(min = 7, message = "Debe tener al menos 7 dígitos")
    private String telefonoPadre;

    @OneToOne
    @JoinColumn(name = "id_usuario", nullable = false, unique = true)
    private Usuario usuario;
}
