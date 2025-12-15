package com.unidadeducativa.academia.nota.dto;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotaBoletinDTO {
    private Long idEstudiante;
    private String nombreEstudiante;
    private String curso;
    private String gestion;
    private List<NotaTrimestreDTO> notas;
}
