package com.unidadeducativa.reportes.controller;

import com.unidadeducativa.reportes.dto.DashboardResponseDTO;
import com.unidadeducativa.reportes.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard", description = "KPIs y Estadísticas")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    public ResponseEntity<DashboardResponseDTO> getStats(java.security.Principal principal) {
        if (principal == null) {
            // Fallback for testing/dev environments if auth is disabled (though
            // PreAuthorize should prevent this)
            // In production this should be 401
            throw new RuntimeException("Usuario no autenticado");
        }
        return ResponseEntity.ok(dashboardService.obtenerEstadisticas(principal.getName()));
    }
}
