package com.unidadeducativa.personas.secretaria.model;

import com.unidadeducativa.usuario.model.Usuario;
import jakarta.persistence.*;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

@Entity
@Table(name = "secretaria")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Secretaria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_secretaria")
    private Long idSecretaria;

    @Column(length = 50)
    @Pattern(regexp = "^[0-9]+$", message = "Solo se permiten dígitos")
    @Size(min = 7, message = "Debe tener al menos 7 dígitos")
    private String telefono;

    @OneToOne
    @JoinColumn(name = "id_usuario", nullable = false, unique = true)
    private Usuario usuario;
}
