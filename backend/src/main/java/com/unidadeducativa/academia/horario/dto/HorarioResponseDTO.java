package com.unidadeducativa.academia.horario.dto;

import com.unidadeducativa.academia.horario.model.DiaSemana;
import lombok.Builder;
import lombok.Data;

import java.time.LocalTime;

@Data
@Builder
public class HorarioResponseDTO {
    private Long idHorario;
    private Long idAsignacion;
    private String nombreMateria;
    private String nombreProfesor;
    private String nombreCurso;
    private DiaSemana diaSemana;
    private LocalTime horaInicio;
    private LocalTime horaFin;
    private String aula;
}
