package com.unidadeducativa.finanzas.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
public class EstadoCuentaDTO {
    private List<ItemEstadoCuentaDTO> mensualidades;
    private List<ItemEstadoCuentaDTO> extras;
    private ResumenCuentaDTO resumen;

    @Data
    @Builder
    public static class ResumenCuentaDTO {
        private BigDecimal totalDeuda;
        private BigDecimal totalPagado;
        private int mensualidadesPagadas;
        private int mensualidadesPendientes;
        private int mensualidadesVencidas;
    }
}
