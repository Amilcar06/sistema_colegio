package com.unidadeducativa.usuario.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UsuarioSinRolRequestDTO {
    @NotBlank(message = "El nombre es obligatorio")
    private String nombres;

    @NotBlank(message = "El apellido paterno es obligatorio")
    private String apellidoPaterno;

    private String apellidoMaterno;

    @NotBlank(message = "El carnet de identidad es obligatorio")
    private String ci;

    @Email(message = "El formato del correo es inválido")
    @NotBlank(message = "El correo es obligatorio")
    private String correo;

    @NotBlank(message = "La contraseña es obligatoria")
    private String contrasena; // Se llamaba "password" en el frontend DTO, pero "contrasena" en el backend
                               // Entity/DTO? Checked UsuarioRequestDTO

    private String fotoPerfil;

    // idRol no se incluye porque se asigna en el backend
}
