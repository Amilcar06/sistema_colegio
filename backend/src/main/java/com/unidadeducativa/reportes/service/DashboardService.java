package com.unidadeducativa.reportes.service;

import com.unidadeducativa.finanzas.repository.PagoRepository;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.reportes.dto.DashboardStatsDTO;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import com.unidadeducativa.shared.enums.RolNombre;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UsuarioRepository usuarioRepository;
    private final PagoRepository pagoRepository;
    private final CuentaCobrarRepository cuentaCobrarRepository;

    public DashboardStatsDTO getStats() {
        long estudiantes = usuarioRepository.countByRol_Nombre(RolNombre.ESTUDIANTE);
        long profesores = usuarioRepository.countByRol_Nombre(RolNombre.PROFESOR);

        // Pagos de hoy (Start of day to End of day)
        LocalDateTime inicioDia = LocalDate.now().atStartOfDay();
        LocalDateTime finDia = LocalDate.now().atTime(23, 59, 59);

        // This assumes PagoRepository has a method roughly like findByFecha
        // pagoBetween...
        // Or we retrieve list and filter. For efficiency we should ideally have a
        // query.
        // But for MVP we can use existing or add a custom query.
        // Let's assume we need to add methods in Repository or do generic count.

        // Simpler approach for now if repositories don't have specific methods:
        // (This might be slow if data is huge, but fine for prototype)
        // Ideally: pagoRepository.sumMontoByFechaPagoBetween(inicioDia, finDia);

        // Since I can't check Repository methods right now without viewing them,
        // I will write the safer code assuming I might need to add repo methods OR
        // implement simple logic.
        // Actually, let's implement the Controller/Service structure first and I'll
        // modify Repositories if needed.

        return DashboardStatsDTO.builder()
                .totalEstudiantes(estudiantes)
                .totalProfesores(profesores)
                .ingresosHoy(BigDecimal.ZERO) // Placeholder until Repo update
                .pagosHoy(0) // Placeholder
                .deudaTotalPendiente(BigDecimal.ZERO) // Placeholder
                .build();
    }
}
