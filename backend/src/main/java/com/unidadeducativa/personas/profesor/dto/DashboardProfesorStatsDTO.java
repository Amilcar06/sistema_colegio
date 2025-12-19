package com.unidadeducativa.personas.profesor.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DashboardProfesorStatsDTO {
    private long totalCursos;
    private long totalEstudiantes;
    private long clasesHoy;
}
