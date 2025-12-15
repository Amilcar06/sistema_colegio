package com.unidadeducativa.academia.gradomateria.controller;

import com.unidadeducativa.academia.gradomateria.dto.GradoMateriaRequestDTO;
import com.unidadeducativa.academia.gradomateria.dto.GradoMateriaResponseDTO;
import com.unidadeducativa.academia.gradomateria.service.IGradoMateriaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/grado-materias")
@RequiredArgsConstructor
@Tag(name = "Grado Materias", description = "Gestión de relación entre grados, materias y gestión académica")
public class GradoMateriaController {

    private final IGradoMateriaService gradoMateriaService;

    // ---------------------------
    // CONSULTAS
    // ---------------------------

    @Operation(summary = "Listar todas las relaciones grado-materia-gestión",
            description = "Devuelve todas las combinaciones registradas de grado, materia y gestión académica.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = GradoMateriaResponseDTO.class))))
    })
    @GetMapping
    public ResponseEntity<List<GradoMateriaResponseDTO>> listar() {
        return ResponseEntity.ok(gradoMateriaService.listar());
    }

    @Operation(summary = "Obtener relación por ID",
            description = "Devuelve los datos de una relación grado-materia-gestión específica mediante su ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Relación encontrada",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = GradoMateriaResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<GradoMateriaResponseDTO> obtener(@PathVariable @Min(1) Long id) {
        return ResponseEntity.ok(gradoMateriaService.obtenerPorId(id));
    }

    // ---------------------------
    // REGISTRO
    // ---------------------------

    @Operation(summary = "Crear nueva relación grado-materia-gestión",
            description = "Permite registrar una nueva combinación entre grado, materia y gestión académica.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Relación creada exitosamente",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = GradoMateriaResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos o duplicados", content = @Content)
    })
    @PostMapping
    public ResponseEntity<GradoMateriaResponseDTO> crear(
            @Valid @RequestBody GradoMateriaRequestDTO dto) {
        return ResponseEntity.ok(gradoMateriaService.crear(dto));
    }

    // ---------------------------
    // ACTUALIZACIÓN
    // ---------------------------

    @Operation(summary = "Actualizar relación grado-materia-gestión",
            description = "Modifica los datos de una relación existente.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Relación actualizada exitosamente",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = GradoMateriaResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos o duplicados", content = @Content),
            @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<GradoMateriaResponseDTO> actualizar(
            @PathVariable @Min(1) Long id,
            @Valid @RequestBody GradoMateriaRequestDTO dto) {
        return ResponseEntity.ok(gradoMateriaService.actualizar(id, dto));
    }

    // ---------------------------
    // ELIMINACIÓN
    // ---------------------------

    @Operation(summary = "Eliminar relación por ID",
            description = "Elimina una relación grado-materia-gestión a partir de su ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Eliminada exitosamente"),
            @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable @Min(1) Long id) {
        gradoMateriaService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
