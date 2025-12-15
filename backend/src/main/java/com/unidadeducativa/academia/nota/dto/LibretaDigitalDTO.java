package com.unidadeducativa.academia.nota.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LibretaDigitalDTO {
    private Long idAsignacion;
    private String materia;
    private String curso;
    private String gestion;
    private List<EstudianteNotaDTO> estudiantes;
}
