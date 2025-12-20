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
    private com.unidadeducativa.personas.estudiante.dto.EstudianteResponseDTO estudiante;

    private Long idCurso;
    private com.unidadeducativa.academia.curso.dto.CursoResponseDTO curso;

    private Long idGestion;
    private Integer anioGestion;

    private LocalDate fechaInscripcion;
    private String estado;
}
