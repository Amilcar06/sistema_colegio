package com.unidadeducativa.academia.inscripcionmateria.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class InscripcionMateriaResponseDTO {

    private Long idInscripcionMateria;

    private Long idInscripcion;

    private Long idMateria;
    private String nombreMateria;
}
