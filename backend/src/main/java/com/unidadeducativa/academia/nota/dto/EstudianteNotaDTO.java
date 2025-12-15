package com.unidadeducativa.academia.nota.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EstudianteNotaDTO {
    private Long idEstudiante;
    private String nombreCompleto;
    private Double notaPrimerTrimestre;
    private Long idNotaPrimerTrimestre;
    private Double notaSegundoTrimestre;
    private Long idNotaSegundoTrimestre;
    private Double notaTercerTrimestre;
    private Long idNotaTercerTrimestre;
}
