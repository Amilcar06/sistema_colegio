package com.unidadeducativa.academia.nota.dto;

import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class NotaBulkRequestDTO {
    @NotEmpty
    private List<NotaRequestDTO> notas;
}
