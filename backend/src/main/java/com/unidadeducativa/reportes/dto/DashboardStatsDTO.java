package com.unidadeducativa.reportes.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDTO {
    private long totalEstudiantes;
    private long totalProfesores;
    private BigDecimal ingresosHoy;
    private long pagosHoy;
    private BigDecimal deudaTotalPendiente;
}
