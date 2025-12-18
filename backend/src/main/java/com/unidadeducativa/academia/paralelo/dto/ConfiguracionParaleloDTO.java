package com.unidadeducativa.academia.paralelo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConfiguracionParaleloDTO {
    private Long id;
    private String nombre;
    private Boolean activo;
    private Integer orden;
}
