package com.unidadeducativa.usuario.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class UsuarioResponseDTO {
    private Long idUsuario;
    private String nombres;
    private String apellidoPaterno;
    private String apellidoMaterno;
    private String ci;
    private String correo;
    private String fotoPerfil;
    private boolean estado;
    private LocalDate fechaNacimiento;
    private RolResponseDTO rol;
}
