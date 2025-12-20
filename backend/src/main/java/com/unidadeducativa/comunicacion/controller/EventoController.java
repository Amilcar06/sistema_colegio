package com.unidadeducativa.comunicacion.controller;

import com.unidadeducativa.comunicacion.dto.EventoRequestDTO;
import com.unidadeducativa.comunicacion.dto.EventoResponseDTO;
import com.unidadeducativa.comunicacion.service.EventoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/eventos")
@RequiredArgsConstructor
@Tag(name = "Comunicación - Eventos", description = "Agenda y calendario escolar")
public class EventoController {

    private final EventoService eventoService;

    @Operation(summary = "Crear un evento (Solo Director)")
    @PreAuthorize("hasRole('ROLE_DIRECTOR')")
    @PostMapping
    public ResponseEntity<EventoResponseDTO> crearEvento(@Valid @RequestBody EventoRequestDTO request) {
        return ResponseEntity.ok(eventoService.crearEvento(request));
    }

    @Operation(summary = "Listar próximos eventos")
    @GetMapping
    public ResponseEntity<List<EventoResponseDTO>> listarEventos() {
        return ResponseEntity.ok(eventoService.listarProximosEventos());
    }

    @Operation(summary = "Listar historial de eventos pasados")
    @GetMapping("/historial")
    public ResponseEntity<List<EventoResponseDTO>> listarHistorialEventos() {
        return ResponseEntity.ok(eventoService.listarHistorialEventos());
    }

    @Operation(summary = "Actualizar evento")
    @PreAuthorize("hasRole('ROLE_DIRECTOR')")
    @PutMapping("/{id}")
    public ResponseEntity<EventoResponseDTO> actualizarEvento(
            @PathVariable Long id,
            @Valid @RequestBody EventoRequestDTO request) {
        return ResponseEntity.ok(eventoService.actualizarEvento(id, request));
    }

    @Operation(summary = "Eliminar evento")
    @PreAuthorize("hasRole('ROLE_DIRECTOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarEvento(@PathVariable Long id) {
        eventoService.eliminarEvento(id);
        return ResponseEntity.noContent().build();
    }
}
