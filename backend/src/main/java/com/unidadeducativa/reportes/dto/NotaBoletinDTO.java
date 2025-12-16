package com.unidadeducativa.reportes.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotaBoletinDTO {
    private String materia;
    private Double nota1; // Trimestre 1
    private Double nota2; // Trimestre 2
    private Double nota3; // Trimestre 3
    private Double promedio;
    private String observacion;
}
