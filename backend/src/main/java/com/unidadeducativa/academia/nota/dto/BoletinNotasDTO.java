package com.unidadeducativa.academia.nota.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class BoletinNotasDTO {
    private Long idEstudiante;
    private String nombreEstudiante;
    private Long idNota; // Puede ser null si aún no tiene nota registrada en este trimestre

    // Dimensiones
    private Double ser;
    private Double saber;
    private Double hacer;
    private Double decidir;
    private Double autoevaluacion;

    private Double notaFinal;
}
