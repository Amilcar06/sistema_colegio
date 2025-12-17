package com.unidadeducativa.reportes.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class DashboardResponseDTO {
    private long totalEstudiantes;
    private long totalProfesores;
    private BigDecimal ingresosHoy;
    private long pagosHoy;
    private BigDecimal deudaTotalPendiente;
}
