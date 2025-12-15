package com.unidadeducativa.finanzas.controller;

import com.unidadeducativa.finanzas.dto.TipoPagoRequestDTO;
import com.unidadeducativa.finanzas.model.TipoPago;
import com.unidadeducativa.finanzas.service.ITipoPagoService;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/finanzas/conceptos")
@RequiredArgsConstructor
@Tag(name = "Finanzas - Tipos de Pago", description = "Gestión de conceptos de cobro (mensualidades, matrículas)")
public class TipoPensionController {

    private final ITipoPagoService tipoPagoService;
    private final UsuarioRepository usuarioRepository;

    @Operation(summary = "Crear nuevo concepto de pago")
    @PostMapping
    public ResponseEntity<TipoPago> create(@Valid @RequestBody TipoPagoRequestDTO request,
            Authentication authentication) {
        Usuario usuario = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        return ResponseEntity.ok(tipoPagoService.crearTipoPago(request, usuario));
    }

    @Operation(summary = "Listar conceptos por gestión")
    @GetMapping("/gestion/{idGestion}")
    public ResponseEntity<List<TipoPago>> listByGestion(@PathVariable Long idGestion, Authentication authentication) {
        Usuario usuario = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        return ResponseEntity.ok(tipoPagoService.listarPorGestion(idGestion, usuario));
    }

    @Operation(summary = "Generar deudas en lote", description = "Asigna este cobro a todos los estudiantes de la Unidad Educativa")
    @PostMapping("/generar-lote/{idTipoPago}")
    public ResponseEntity<Void> generateDebts(@PathVariable Long idTipoPago, Authentication authentication) {
        Usuario usuario = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        tipoPagoService.generarDeudasLote(idTipoPago, usuario);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Actualizar concepto de pago")
    @PutMapping("/{id}")
    public ResponseEntity<TipoPago> update(@PathVariable Long id, @Valid @RequestBody TipoPagoRequestDTO request,
            Authentication authentication) {
        Usuario usuario = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        return ResponseEntity.ok(tipoPagoService.actualizarTipoPago(id, request, usuario));
    }

    @Operation(summary = "Eliminar concepto de pago")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id, Authentication authentication) {
        Usuario usuario = usuarioRepository.findByCorreo(authentication.getName()).orElseThrow();
        tipoPagoService.eliminarTipoPago(id, usuario);
        return ResponseEntity.noContent().build();
    }
}
