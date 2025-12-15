package com.unidadeducativa.personas.estudiante.dto;

import com.unidadeducativa.usuario.dto.RolResponseDTO;
import lombok.Data;

import java.time.LocalDate;

@Data
public class EstudianteResponseDTO {

    // ==== Estudiante ====
    private Long idEstudiante;
    private String direccion;
    private String nombreMadre;
    private String telefonoMadre;
    private String nombrePadre;
    private String telefonoPadre;

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
