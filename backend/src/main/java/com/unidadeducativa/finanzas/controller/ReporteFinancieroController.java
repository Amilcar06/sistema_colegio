package com.unidadeducativa.finanzas.controller;

import com.unidadeducativa.finanzas.dto.ReporteIngresosDTO;
import com.unidadeducativa.finanzas.service.IPagoService;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/finanzas/reportes")
@RequiredArgsConstructor
@Tag(name = "Finanzas - Reportes", description = "Reportes financieros y de caja")
public class ReporteFinancieroController {

    private final IPagoService pagoService;
    private final UsuarioRepository usuarioRepository;

    @Operation(summary = "Reporte de Ingresos por Fechas")
    @GetMapping("/ingresos")
    public ResponseEntity<ReporteIngresosDTO> getIngresos(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fin,
            Authentication authentication) {
        Usuario usuario = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        return ResponseEntity.ok(pagoService.generarReporteIngresos(inicio, fin, usuario));
    }
}
