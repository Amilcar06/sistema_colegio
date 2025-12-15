package com.unidadeducativa.academia.gestion.controller;

import com.unidadeducativa.academia.gestion.dto.GestionRequestDTO;
import com.unidadeducativa.academia.gestion.dto.GestionResponseDTO;
import com.unidadeducativa.academia.gestion.dto.GestionUpdateDTO;
import com.unidadeducativa.academia.gestion.service.IGestionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/gestion")
@RequiredArgsConstructor
@Tag(name = "Gestión Académica", description = "Operaciones relacionadas con la gestión académica")
public class GestionAcademicaController {

    private final IGestionService gestionService;

    // ---------------------------
    // LISTAR TODAS LAS GESTIONES
    // ---------------------------

    @Operation(summary = "Listar gestiones académicas", description = "Devuelve todas las gestiones registradas.")
    @ApiResponse(responseCode = "200", description = "Gestiones listadas correctamente",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = GestionResponseDTO.class))))
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @GetMapping
    public ResponseEntity<List<GestionResponseDTO>> listar() {
        return ResponseEntity.ok(gestionService.listarGestiones());
    }

    // ---------------------------
    // REGISTRAR GESTIÓN
    // ---------------------------

    @Operation(summary = "Registrar nueva gestión académica",
            description = "Crea una nueva gestión académica automáticamente para el año actual. "
                    + "No se permite más de una gestión por año.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Gestión registrada correctamente",
                    content = @Content(schema = @Schema(implementation = GestionResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Ya existe gestión para el año actual")
    })
    @PreAuthorize("hasRole('ROLE_DIRECTOR')")
    @PostMapping
    public ResponseEntity<GestionResponseDTO> registrar(@Valid @RequestBody GestionRequestDTO dto) {
        return ResponseEntity.ok(gestionService.registrarGestion(dto));
    }

    // ---------------------------
    // OBTENER GESTIÓN ACTUAL
    // ---------------------------

    @Operation(summary = "Obtener gestión académica actual",
            description = "Devuelve la gestión académica correspondiente al año actual si existe.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Gestión actual encontrada",
                    content = @Content(schema = @Schema(implementation = GestionResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "No existe gestión para el año actual")
    })
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @GetMapping("/actual")
    public ResponseEntity<GestionResponseDTO> obtenerActual() {
        return ResponseEntity.ok(gestionService.obtenerGestionActual());
    }

    // ---------------------------
    // ACTUALIZAR GESTIÓN
    // ---------------------------

    @Operation(summary = "Actualizar gestión académica", description = "Permite actualizar el estado de una gestión.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Gestión actualizada correctamente",
                    content = @Content(schema = @Schema(implementation = GestionResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "Gestión no encontrada")
    })
    @PreAuthorize("hasRole('ROLE_DIRECTOR')")
    @PutMapping("/{id}")
    public ResponseEntity<GestionResponseDTO> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody GestionUpdateDTO dto) {
        return ResponseEntity.ok(gestionService.actualizarGestion(id, dto));
    }

    // ---------------------------
    // ELIMINAR GESTIÓN
    // ---------------------------

    @Operation(summary = "Eliminar gestión académica", description = "Elimina una gestión académica existente.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Gestión eliminada correctamente"),
            @ApiResponse(responseCode = "404", description = "Gestión no encontrada")
    })
    @PreAuthorize("hasRole('ROLE_DIRECTOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        gestionService.eliminarGestion(id);
        return ResponseEntity.noContent().build();
    }
}
