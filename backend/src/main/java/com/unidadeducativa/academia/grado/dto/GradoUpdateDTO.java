package com.unidadeducativa.academia.grado.dto;

import com.unidadeducativa.shared.enums.TipoNivel;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GradoUpdateDTO {
    @NotBlank
    private String nombre;

    @NotNull
    private TipoNivel nivel;
}
