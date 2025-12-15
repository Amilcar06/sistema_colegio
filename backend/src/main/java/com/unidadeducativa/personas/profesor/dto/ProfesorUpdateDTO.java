package com.unidadeducativa.personas.profesor.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import lombok.Data;

import java.time.LocalDate;

@Data
public class ProfesorUpdateDTO {
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

    private String fotoPerfil;

    @NotNull
    @Past
    private LocalDate fechaNacimiento;

    // ==== Profesor ====
    @NotBlank
    private String telefono;

    @NotBlank
    private String profesion;
}
