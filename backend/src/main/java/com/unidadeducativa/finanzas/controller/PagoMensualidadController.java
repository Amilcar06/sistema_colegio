package com.unidadeducativa.finanzas.controller;

import com.unidadeducativa.finanzas.dto.CuentaCobrarResponseDTO;
import com.unidadeducativa.finanzas.dto.PagoRequestDTO;
import com.unidadeducativa.finanzas.dto.PagoResponseDTO;
import com.unidadeducativa.finanzas.service.IPagoService;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/finanzas/pagos")
@RequiredArgsConstructor
@Tag(name = "Finanzas - Caja", description = "Registro de pagos y consulta de deudas")
public class PagoMensualidadController {

    private final IPagoService pagoService;
    private final UsuarioRepository usuarioRepository;

    @Operation(summary = "Registrar un pago")
    @PostMapping
    public ResponseEntity<PagoResponseDTO> registrarPago(@Valid @RequestBody PagoRequestDTO request,
            Authentication authentication) {
        Usuario cajero = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        return ResponseEntity.ok(pagoService.registrarPago(request, cajero));
    }

    @Operation(summary = "Ver estado de cuenta del estudiante")
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_SECRETARIA', 'ROLE_ESTUDIANTE', 'ROLE_ALUMNO')")
    @GetMapping("/estudiante/{idEstudiante}")
    public ResponseEntity<List<CuentaCobrarResponseDTO>> listarDeudas(@PathVariable Long idEstudiante) {
        return ResponseEntity.ok(pagoService.listarDeudasEstudiante(idEstudiante));
    }

    @Operation(summary = "Ver historial de pagos de una cuenta")
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_SECRETARIA', 'ROLE_ESTUDIANTE', 'ROLE_ALUMNO')")
    @GetMapping("/cuenta/{idCuenta}")
    public ResponseEntity<List<PagoResponseDTO>> listarPagosPorCuenta(@PathVariable Long idCuenta) {
        return ResponseEntity.ok(pagoService.listarPagosPorCuenta(idCuenta));
    }

    @Operation(summary = "Listar pagos (filtro opcional por estudiante)")
    @GetMapping
    public ResponseEntity<List<PagoResponseDTO>> listarPagosGeneral(
            @RequestParam(required = false) Long idEstudiante) {
        if (idEstudiante != null) {
            return ResponseEntity.ok(pagoService.listarPagosPorEstudiante(idEstudiante));
        }
        // Si no se envía ID, podríamos devolver vacío o todo (por ahora vacío para
        // evitar carga masiva)
        return ResponseEntity.ok(List.of());
    }
}
