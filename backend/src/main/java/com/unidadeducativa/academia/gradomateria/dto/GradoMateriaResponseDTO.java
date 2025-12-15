package com.unidadeducativa.academia.gradomateria.dto;

import lombok.Data;

@Data
public class GradoMateriaResponseDTO {
    private Long idGradoMateria;
    private Long idGrado;
    private String nombreGrado;
    private Long idMateria;
    private String nombreMateria;
    private Long idGestion;
    private String anioGestion;
}
