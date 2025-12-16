package com.unidadeducativa.reportes.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ListaCursoDTO {
    private Integer nroLista;
    private String nombreEstudiante;
    private String codigoRude;
}
