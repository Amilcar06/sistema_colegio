package com.unidadeducativa.personas.estudiante.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;

@Data
public class EstudianteRequestDTO {
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

    private String contrasena;

    private String fotoPerfil;

    @NotNull(message = "La fecha de nacimiento es obligatoria")
    @Past(message = "La fecha de nacimiento debe estar en el pasado")
    private LocalDate fechaNacimiento;

    // ==== Estudiante ====
    @NotBlank(message = "La dirección es obligatoria")
    private String direccion;

    private String nombreMadre;

    @Pattern(regexp = "^[0-9]+$", message = "Solo se permiten dígitos")
    @Size(min = 7, message = "Debe tener al menos 7 dígitos")
    private String telefonoMadre;

    private String nombrePadre;

    @Pattern(regexp = "^[0-9]+$", message = "Solo se permiten dígitos")
    @Size(min = 7, message = "Debe tener al menos 7 dígitos")
    private String telefonoPadre;
}
