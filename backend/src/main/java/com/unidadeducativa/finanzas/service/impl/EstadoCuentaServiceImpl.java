package com.unidadeducativa.finanzas.service.impl;

import com.unidadeducativa.finanzas.dto.EstadoCuentaDTO;
import com.unidadeducativa.finanzas.dto.ItemEstadoCuentaDTO;
import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.service.IEstadoCuentaService;
import com.unidadeducativa.shared.enums.CategoriaPago;
import com.unidadeducativa.shared.enums.EstadoPago;
import com.unidadeducativa.usuario.model.Usuario;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EstadoCuentaServiceImpl implements IEstadoCuentaService {

    private final CuentaCobrarRepository cuentaCobrarRepository;

    @Override
    @Transactional(readOnly = true)
    public EstadoCuentaDTO obtenerEstadoCuenta(Long idEstudiante, Usuario usuarioAuditor) {
        // En futuro, validar que usuarioAuditor tenga permiso de ver este estudiante
        // (Director, Secre o el mismo estudiante)

        List<CuentaCobrar> cuentas = cuentaCobrarRepository.findByEstudiante_IdEstudiante(idEstudiante);

        List<ItemEstadoCuentaDTO> mensualidades = new ArrayList<>();
        List<ItemEstadoCuentaDTO> extras = new ArrayList<>();

        BigDecimal totalDeuda = BigDecimal.ZERO;
        BigDecimal totalPagado = BigDecimal.ZERO;
        int mensualidadesPagadas = 0;
        int mensualidadesPendientes = 0;
        int mensualidadesVencidas = 0;

        for (CuentaCobrar c : cuentas) {
            boolean esMensualidad = c.getTipoPago().getCategoria() == CategoriaPago.MENSUALIDAD;

            // Calculo retraso
            Integer diasRetraso = 0;
            if (c.getEstado() == EstadoPago.PENDIENTE && c.getFechaVencimiento() != null
                    && LocalDate.now().isAfter(c.getFechaVencimiento())) {
                diasRetraso = (int) ChronoUnit.DAYS.between(c.getFechaVencimiento(), LocalDate.now());
                if (esMensualidad)
                    mensualidadesVencidas++;
            } else if (c.getEstado() == EstadoPago.PENDIENTE && esMensualidad) {
                mensualidadesPendientes++;
            } else if (c.getEstado() == EstadoPago.PAGADO && esMensualidad) {
                mensualidadesPagadas++;
            }

            if (c.getEstado() == EstadoPago.PENDIENTE) {
                totalDeuda = totalDeuda.add(c.getSaldoPendiente());
            } else if (c.getEstado() == EstadoPago.PAGADO) {
                totalPagado = totalPagado.add(c.getMonto()); // Asumimos pagado completo
            }

            ItemEstadoCuentaDTO item = ItemEstadoCuentaDTO.builder()
                    .idCuentaCobrar(c.getIdCuentaCobrar())
                    .concepto(c.getTipoPago().getNombre())
                    .monto(c.getMonto())
                    .saldoPendiente(c.getSaldoPendiente())
                    .estado(c.getEstado())
                    .fechaVencimiento(c.getFechaVencimiento())
                    .diasRetraso(diasRetraso)
                    .esMensualidad(esMensualidad)
                    .build();

            if (esMensualidad) {
                mensualidades.add(item);
            } else {
                extras.add(item);
            }
        }

        // Sort mensualidades by ID or Name? Usually chronological. Assuming generated
        // in order or ID order.
        // Let's sort by ID to be safe or date logic if available.
        // We'll trust DB order for now or sort by ID.
        mensualidades.sort((a, b) -> a.getIdCuentaCobrar().compareTo(b.getIdCuentaCobrar()));

        EstadoCuentaDTO.ResumenCuentaDTO resumen = EstadoCuentaDTO.ResumenCuentaDTO.builder()
                .totalDeuda(totalDeuda)
                .totalPagado(totalPagado)
                .mensualidadesPagadas(mensualidadesPagadas)
                .mensualidadesPendientes(mensualidadesPendientes)
                .mensualidadesVencidas(mensualidadesVencidas)
                .build();

        return EstadoCuentaDTO.builder()
                .mensualidades(mensualidades)
                .extras(extras)
                .resumen(resumen)
                .build();
    }
}
