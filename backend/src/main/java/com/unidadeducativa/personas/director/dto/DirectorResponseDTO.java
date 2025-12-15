package com.unidadeducativa.personas.director.dto;

import com.unidadeducativa.usuario.dto.RolResponseDTO;
import lombok.Data;

import java.time.LocalDate;

@Data
public class DirectorResponseDTO {
    // ==== Director ====
    private Long idDirector;
    private String telefono;

    // ==== Usuario ====
    private Long idUsuario;
    private String nombres;
    private String apellidoPaterno;
    private String apellidoMaterno;
    private String ci;
    private String correo;
    private String fotoPerfil;
    private LocalDate fechaNacimiento;
    private boolean estado;

    private RolResponseDTO rol;
}
