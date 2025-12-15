package com.unidadeducativa.academia.asignaciondocente.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class AsignacionDocenteRequestDTO {

    @NotNull(message = "El ID del profesor es obligatorio")
    private Long idProfesor;

    @NotNull(message = "El ID de la materia es obligatorio")
    private Long idMateria;

    @NotNull(message = "El ID del curso es obligatorio")
    private Long idCurso;

    @NotNull(message = "El ID de la gestión académica es obligatorio")
    private Long idGestion;

    private Boolean estado = true;

    private LocalDate fechaInicio;

    private LocalDate fechaFin;
}
