package com.unidadeducativa.academia.grado.dto;

import com.unidadeducativa.shared.enums.TipoNivel;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GradoResponseDTO {
    private Long idGrado;
    private String nombre;
    private TipoNivel nivel;
}
