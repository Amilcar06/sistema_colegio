package com.unidadeducativa.reportes.service;

import com.unidadeducativa.finanzas.repository.PagoRepository;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.reportes.dto.DashboardStatsDTO;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import com.unidadeducativa.shared.enums.RolNombre;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;
import com.unidadeducativa.reportes.dto.DashboardResponseDTO;
import com.unidadeducativa.finanzas.model.Pago;

@Service
@RequiredArgsConstructor
public class DashboardService {

        private final UsuarioRepository usuarioRepository;
        private final PagoRepository pagoRepository;

        public DashboardResponseDTO obtenerEstadisticas(Long idUnidadEducativa) {
                long totalEstudiantes = usuarioRepository.countByRol_NombreAndUnidadEducativa_IdUnidadEducativa(
                                RolNombre.ESTUDIANTE,
                                idUnidadEducativa);
                long totalProfesores = usuarioRepository.countByRol_NombreAndUnidadEducativa_IdUnidadEducativa(
                                RolNombre.PROFESOR,
                                idUnidadEducativa);

                // Financiero
                LocalDateTime inicioDia = LocalDate.now().atStartOfDay();
                LocalDateTime finDia = LocalDate.now().atTime(LocalTime.MAX);

                List<Pago> pagosHoy = pagoRepository
                                .findByFechaPagoBetweenAndCuentaCobrar_TipoPago_UnidadEducativa_IdUnidadEducativa(
                                                inicioDia, finDia, idUnidadEducativa);

                BigDecimal ingresosHoy = pagosHoy.stream()
                                .map(Pago::getMontoPagado)
                                .reduce(BigDecimal.ZERO, BigDecimal::add);

                return DashboardResponseDTO.builder()
                                .totalEstudiantes(totalEstudiantes)
                                .totalProfesores(totalProfesores)
                                .ingresosHoy(ingresosHoy)
                                .pagosHoy((long) pagosHoy.size())
                                .deudaTotalPendiente(BigDecimal.ZERO)
                                .build();
        }
}
