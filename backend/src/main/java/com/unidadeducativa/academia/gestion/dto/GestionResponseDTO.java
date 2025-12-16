package com.unidadeducativa.academia.gestion.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GestionResponseDTO {
    private Long idGestion;
    private Integer anio;
    private Boolean estado;
}