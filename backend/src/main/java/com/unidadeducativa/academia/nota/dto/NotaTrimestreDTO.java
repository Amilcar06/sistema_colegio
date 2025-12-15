package com.unidadeducativa.academia.nota.dto;

import com.unidadeducativa.shared.enums.Trimestre;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotaTrimestreDTO {
    private Trimestre trimestre;
    private String materia;
    private Double valor;
    private String nombreProfesor;
}
