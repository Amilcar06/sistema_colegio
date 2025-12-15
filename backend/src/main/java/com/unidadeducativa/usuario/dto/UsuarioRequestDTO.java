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
    private String nombres;

    @NotBlank
    private String apellidoPaterno;

    private String apellidoMaterno;

    @NotBlank
    @Size(min = 5, max = 50)
    private String ci;

    @NotBlank
    @Email
    private String correo;

    @NotBlank
    private String contrasena;

    @NotNull
    private Long idRol;

    private boolean estado = true;

    private String fotoPerfil;

    private LocalDate fechaNacimiento;
}
