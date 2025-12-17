package com.unidadeducativa.usuario.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UsuarioRequestDTO {
    @NotBlank
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    private String nombres;

    @NotBlank
    @Size(min = 2, max = 50, message = "El apellido paterno debe tener entre 2 y 50 caracteres")
    private String apellidoPaterno;

    @Size(min = 2, max = 50, message = "El apellido materno debe tener entre 2 y 50 caracteres")
    private String apellidoMaterno;

    @NotBlank
    @Size(min = 5, max = 20, message = "El CI debe tener entre 5 y 20 caracteres")
    private String ci;

    @NotBlank
    @Email
    private String correo;

    @NotBlank
    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
    private String contrasena;

    @NotNull
    private Long idRol;

    private boolean estado = true;

    private String fotoPerfil;

    private LocalDate fechaNacimiento;
}
