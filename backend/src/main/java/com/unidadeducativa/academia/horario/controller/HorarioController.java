package com.unidadeducativa.academia.horario.controller;

import com.unidadeducativa.academia.horario.dto.HorarioRequestDTO;
import com.unidadeducativa.academia.horario.dto.HorarioResponseDTO;
import com.unidadeducativa.academia.horario.service.HorarioService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/horarios")
@RequiredArgsConstructor
@Tag(name = "Horarios", description = "Gestión de horarios de clases")
public class HorarioController {

    private final HorarioService service;

    @Operation(summary = "Crear nuevo horario")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @PostMapping
    public ResponseEntity<HorarioResponseDTO> crear(@Valid @RequestBody HorarioRequestDTO dto) {
        return ResponseEntity.ok(service.crear(dto));
    }

    @Operation(summary = "Listar horarios de un curso")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_ALUMNO', 'ROLE_PROFESOR')")
    @GetMapping("/curso/{idCurso}")
    public ResponseEntity<List<HorarioResponseDTO>> listarPorCurso(@PathVariable Long idCurso) {
        return ResponseEntity.ok(service.listarPorCurso(idCurso));
    }

    @Operation(summary = "Listar horarios de un profesor")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR')")
    @GetMapping("/profesor/{idProfesor}")
    public ResponseEntity<List<HorarioResponseDTO>> listarPorProfesor(@PathVariable Long idProfesor) {
        return ResponseEntity.ok(service.listarPorProfesor(idProfesor));
    }

    @Operation(summary = "Eliminar horario")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        service.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
