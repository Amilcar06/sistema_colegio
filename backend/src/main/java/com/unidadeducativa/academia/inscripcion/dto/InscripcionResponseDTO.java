package com.unidadeducativa.academia.inscripcion.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InscripcionResponseDTO {
    private Long idInscripcion;
    private Long idEstudiante;
    private String nombreEstudiante;

    private Long idCurso;
    private String nombreCurso;

    private Long idGestion;
    private Integer anioGestion;

    private LocalDate fechaInscripcion;
    private String estado;
}
