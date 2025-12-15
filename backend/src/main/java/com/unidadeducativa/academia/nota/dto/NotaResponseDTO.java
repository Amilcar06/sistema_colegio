package com.unidadeducativa.academia.nota.dto;

import com.unidadeducativa.shared.enums.Trimestre;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotaResponseDTO {
    private Long idNota;
    private Long idEstudiante;
    private String nombreEstudiante;
    private Long idAsignacion;
    private String nombreMateria;
    private String nombreProfesor;
    private Double valor;
    private Trimestre trimestre;
    private String fechaRegistro;
}
