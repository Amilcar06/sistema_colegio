package com.unidadeducativa.academia.curso.dto;

import com.unidadeducativa.shared.enums.TipoNivel;
import com.unidadeducativa.shared.enums.TipoTurno;
import lombok.Data;

@Data
public class CursoResponseDTO {

    private Long idCurso;

    // Info del grado asociado
    private Long idGrado;
    private String nombreGrado;
    private TipoNivel nivel;

    private String paralelo;
    private TipoTurno turno;
}
