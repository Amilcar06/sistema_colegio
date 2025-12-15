package com.unidadeducativa.personas.secretaria.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import lombok.Data;

import java.time.LocalDate;

@Data
public class SecretariaRequestDTO {
    // ==== Usuario ====
    @NotBlank
    private String nombres;

    @NotBlank
    private String apellidoPaterno;

    private String apellidoMaterno;

    @NotBlank(message = "El CI es obligatorio")
    private String ci;

    @NotBlank
    @Email
    private String correo;

    @NotBlank
    private String contrasena;

    private String fotoPerfil;

    @NotNull(message = "La fecha de nacimiento es obligatoria")
    @Past(message = "La fecha de nacimiento debe estar en el pasado")
    private LocalDate fechaNacimiento;

    // ==== Secretaria ====

    @NotBlank(message = "El teléfono es obligatorio")
    private String telefono;

}
