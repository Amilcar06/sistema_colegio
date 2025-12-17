package com.unidadeducativa.personas.estudiante.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;

@Data
public class EstudianteRequestDTO {
    // ==== Usuario ====
    @NotBlank
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    private String nombres;

    @NotBlank
    @Size(min = 2, max = 50, message = "El apellido paterno debe tener entre 2 y 50 caracteres")
    private String apellidoPaterno;

    @Size(min = 2, max = 50, message = "El apellido materno debe tener entre 2 y 50 caracteres")
    private String apellidoMaterno;

    @NotBlank(message = "El CI es obligatorio")
    @Size(min = 5, max = 20, message = "El CI debe tener entre 5 y 20 caracteres")
    private String ci;

    @NotBlank
    @Email
    private String correo;

    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
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
