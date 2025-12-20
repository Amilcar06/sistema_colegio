package com.unidadeducativa.reportes.controller;

import com.unidadeducativa.reportes.service.ReporteFinancieroService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
@CrossOrigin(originPatterns = "*") // Fix CORS with Credentials, use correct attribute name
public class ReporteFinancieroController {

    private final ReporteFinancieroService reporteFinancieroService;

    // Reporte de Ingresos Diarios por Mes
    @GetMapping("/ingresos")
    @PreAuthorize("hasRole('DIRECTOR') or hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getReporteIngresos(
            Principal principal,
            @RequestParam(defaultValue = "2025") int year,
            @RequestParam(defaultValue = "1") int month) {
        String correo = principal.getName();
        return ResponseEntity.ok(
                reporteFinancieroService.obtenerReporteIngresos(correo, year, month));
    }

    // Lista de Morosos
    @GetMapping("/morosos")
    @PreAuthorize("hasRole('DIRECTOR') or hasRole('ADMIN')")
    public ResponseEntity<List<Map<String, Object>>> getListaMorosos(Principal principal) {
        String correo = principal.getName();
        return ResponseEntity.ok(
                reporteFinancieroService.obtenerListaMorosos(correo));
    }

    // Ultimas Transacciones
    @GetMapping("/transacciones")
    @PreAuthorize("hasRole('DIRECTOR') or hasRole('ADMIN')")
    public ResponseEntity<List<Map<String, Object>>> getUltimasTransacciones(Principal principal) {
        String correo = principal.getName();
        return ResponseEntity.ok(
                reporteFinancieroService.obtenerUltimasTransacciones(correo));
    }

    // Cierre Diario (Secretaria)
    @GetMapping("/cierre-diario")
    @PreAuthorize("hasRole('DIRECTOR') or hasRole('ADMIN') or hasRole('SECRETARIA')")
    public ResponseEntity<Map<String, Object>> getCierreDiario(
            Principal principal,
            @RequestParam(required = false) String fecha) {
        String correo = principal.getName();
        java.time.LocalDate date = (fecha != null) ? java.time.LocalDate.parse(fecha) : java.time.LocalDate.now();
        return ResponseEntity.ok(
                reporteFinancieroService.obtenerCierreDiario(correo, date));
    }
}
