package com.unidadeducativa.personas.estudiante.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import lombok.Data;

import java.time.LocalDate;

@Data
public class EstudianteUpdateDTO {

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

    // ==== Estudiante ====
    @NotBlank
    private String direccion;

    private String nombreMadre;

    @NotBlank
    private String telefonoMadre;

    private String nombrePadre;

    @NotBlank
    private String telefonoPadre;
}
