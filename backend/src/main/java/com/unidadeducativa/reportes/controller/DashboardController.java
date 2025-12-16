package com.unidadeducativa.reportes.controller;

import com.unidadeducativa.reportes.dto.DashboardStatsDTO;
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

    @Operation(summary = "Obtener estadísticas generales (Director)")
    @PreAuthorize("hasRole('ROLE_DIRECTOR')")
    @GetMapping("/stats")
    public ResponseEntity<DashboardStatsDTO> getStats() {
        return ResponseEntity.ok(dashboardService.getStats());
    }
}
