package com.unidadeducativa.academia.horario.dto;

import com.unidadeducativa.academia.horario.model.DiaSemana;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalTime;

@Data
public class HorarioRequestDTO {
    @NotNull(message = "El ID de asignación docente es obligatorio")
    private Long idAsignacion;

    @NotNull(message = "El día de la semana es obligatorio")
    private DiaSemana diaSemana;

    @NotNull(message = "La hora de inicio es obligatoria")
    private LocalTime horaInicio;

    @NotNull(message = "La hora de fin es obligatoria")
    private LocalTime horaFin;

    private String aula;
}
