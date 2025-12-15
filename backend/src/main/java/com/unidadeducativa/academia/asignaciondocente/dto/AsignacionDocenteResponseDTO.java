package com.unidadeducativa.academia.asignaciondocente.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class AsignacionDocenteResponseDTO {
    private Long idAsignacion;
    private Long idProfesor;
    private String nombreProfesor;
    private Long idMateria;
    private String nombreMateria;
    private Long idCurso;
    private String nombreCurso;
    private Long idGestion;
    private Integer anioGestion;
    private Boolean estado;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}
