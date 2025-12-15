package com.unidadeducativa.personas.profesor.model;

import com.unidadeducativa.usuario.model.Usuario;
import jakarta.persistence.*;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

@Entity
@Table(name = "profesor")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Profesor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_profesor")
    private Long idProfesor;

    @Column(length = 50)
    @Pattern(regexp = "^[0-9]+$", message = "Solo se permiten dígitos")
    @Size(min = 7, message = "Debe tener al menos 7 dígitos")
    private String telefono;

    @Column(length = 255)
    private String profesion;

    @OneToOne
    @JoinColumn(name = "id_usuario", nullable = false, unique = true)
    private Usuario usuario;
}
