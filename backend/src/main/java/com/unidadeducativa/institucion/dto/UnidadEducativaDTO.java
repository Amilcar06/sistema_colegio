package com.unidadeducativa.institucion.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UnidadEducativaDTO {

    private Long idUnidadEducativa;

    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @NotBlank(message = "El código SIE es obligatorio")
    private String sie;

    private String direccion;

    private String logoUrl;
}
