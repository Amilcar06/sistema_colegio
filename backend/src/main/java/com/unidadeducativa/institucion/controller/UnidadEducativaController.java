package com.unidadeducativa.institucion.controller;

import com.unidadeducativa.institucion.dto.UnidadEducativaDTO;
import com.unidadeducativa.institucion.service.UnidadEducativaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/institucion")
@RequiredArgsConstructor
@Tag(name = "Configuración Institucional", description = "Gestión de datos de la Unidad Educativa")
public class UnidadEducativaController {

    private final UnidadEducativaService service;

    @Operation(summary = "Obtener datos de la institución")
    @GetMapping
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_ADMIN', 'ROLE_SECRETARIA')")
    public ResponseEntity<UnidadEducativaDTO> obtener() {
        return ResponseEntity.ok(service.obtenerPrincipal());
    }

    @Operation(summary = "Actualizar datos de la institución")
    @PutMapping
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_ADMIN')")
    public ResponseEntity<UnidadEducativaDTO> actualizar(@Valid @RequestBody UnidadEducativaDTO dto) {
        return ResponseEntity.ok(service.actualizarPrincipal(dto));
    }
}
