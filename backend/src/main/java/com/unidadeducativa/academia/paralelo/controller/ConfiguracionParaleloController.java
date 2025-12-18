package com.unidadeducativa.academia.paralelo.controller;

import com.unidadeducativa.academia.paralelo.dto.ConfiguracionParaleloDTO;
import com.unidadeducativa.academia.paralelo.service.ConfiguracionParaleloService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/configuracion/paralelos")

@RequiredArgsConstructor
@Tag(name = "Configuración de Paralelos", description = "Gestión de paralelos habilitados")
public class ConfiguracionParaleloController {

    private final ConfiguracionParaleloService service;

    @Operation(summary = "Listar todos los paralelos configurados")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_ADMIN')")
    @GetMapping
    public ResponseEntity<List<ConfiguracionParaleloDTO>> listarTodos() {
        System.out.println("Entrando a listarTodos paralelos");
        return ResponseEntity.ok(service.listarTodos());
    }

    @Operation(summary = "Cambiar estado (activo/inactivo) de un paralelo")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_ADMIN')")
    @PatchMapping("/{id}")
    public ResponseEntity<ConfiguracionParaleloDTO> cambiarEstado(
            @PathVariable Long id,
            @RequestBody Map<String, Boolean> body) {
        Boolean activo = body.get("activo");
        if (activo == null) {
            throw new IllegalArgumentException("El campo 'activo' es requerido");
        }
        return ResponseEntity.ok(service.cambiarEstado(id, activo));
    }
}
