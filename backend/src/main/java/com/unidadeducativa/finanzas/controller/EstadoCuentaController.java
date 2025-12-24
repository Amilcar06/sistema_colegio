package com.unidadeducativa.finanzas.controller;

import com.unidadeducativa.finanzas.dto.EstadoCuentaDTO;
import com.unidadeducativa.finanzas.service.IEstadoCuentaService;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/finanzas/estado-cuentas")
@RequiredArgsConstructor
@Tag(name = "Finanzas - Estado de Cuentas", description = "Visualización de deudas y pagos por estudiante")
public class EstadoCuentaController {

    private final IEstadoCuentaService estadoCuentaService;
    private final UsuarioRepository usuarioRepository;

    @Operation(summary = "Obtener estado de cuenta consolidado", description = "Retorna mensualidades y extras separados, con resumen de deuda.")
    @GetMapping("/{idEstudiante}")
    public ResponseEntity<EstadoCuentaDTO> getAccountStatus(@PathVariable Long idEstudiante,
            Authentication authentication) {
        Usuario usuarioAuditor = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        return ResponseEntity.ok(estadoCuentaService.obtenerEstadoCuenta(idEstudiante, usuarioAuditor));
    }
}
