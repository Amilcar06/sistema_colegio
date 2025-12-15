package com.unidadeducativa.academia.materia.controller;

import com.unidadeducativa.academia.materia.dto.MateriaRequestDTO;
import com.unidadeducativa.academia.materia.dto.MateriaResponseDTO;
import com.unidadeducativa.academia.materia.service.IMateriaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/materias")
@RequiredArgsConstructor
@Tag(name = "Materias", description = "Gestión de materias por nivel educativo")
public class MateriaController {

        private final IMateriaService materiaService;

        // ---------------------------
        // CONSULTAS
        // ---------------------------

        @Operation(summary = "Listar todas las materias", description = "Devuelve una lista completa de todas las materias registradas.")
        @ApiResponses(value = {
                        @ApiResponse(responseCode = "200", description = "Lista de materias", content = @Content(array = @ArraySchema(schema = @Schema(implementation = MateriaResponseDTO.class))))
        })
        @GetMapping
        public ResponseEntity<List<MateriaResponseDTO>> listar() {
                return ResponseEntity.ok(materiaService.listarMaterias());
        }

        @Operation(summary = "Obtener materia por ID", description = "Devuelve los datos de una materia específica mediante su ID.")
        @ApiResponses(value = {
                        @ApiResponse(responseCode = "200", description = "Materia encontrada", content = @Content(mediaType = "application/json", schema = @Schema(implementation = MateriaResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Materia no encontrada", content = @Content)
        })
        @GetMapping("/{id}")
        public ResponseEntity<MateriaResponseDTO> obtener(@PathVariable @Min(1) Long id) {
                return ResponseEntity.ok(materiaService.obtenerMateria(id));
        }

        // ---------------------------
        // REGISTRO
        // ---------------------------

        @Operation(summary = "Crear materia", description = "Permite registrar una nueva materia para un nivel específico.")
        @ApiResponses(value = {
                        @ApiResponse(responseCode = "200", description = "Materia creada exitosamente", content = @Content(mediaType = "application/json", schema = @Schema(implementation = MateriaResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content)
        })
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        @PostMapping
        public ResponseEntity<MateriaResponseDTO> crear(
                        @Valid @RequestBody MateriaRequestDTO dto) {
                return ResponseEntity.ok(materiaService.crearMateria(dto));
        }

        // ---------------------------
        // ACTUALIZACIÓN
        // ---------------------------

        @Operation(summary = "Actualizar materia", description = "Actualiza los datos de una materia existente.")
        @ApiResponses(value = {
                        @ApiResponse(responseCode = "200", description = "Materia actualizada exitosamente", content = @Content(mediaType = "application/json", schema = @Schema(implementation = MateriaResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Materia no encontrada", content = @Content)
        })
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        @PutMapping("/{id}")
        public ResponseEntity<MateriaResponseDTO> actualizar(
                        @PathVariable Long id,
                        @Valid @RequestBody MateriaRequestDTO dto) {
                return ResponseEntity.ok(materiaService.actualizarMateria(id, dto));
        }

        // ---------------------------
        // ELIMINACIÓN
        // ---------------------------

        @Operation(summary = "Eliminar materia", description = "Elimina una materia por su ID.")
        @ApiResponses(value = {
                        @ApiResponse(responseCode = "204", description = "Materia eliminada exitosamente"),
                        @ApiResponse(responseCode = "404", description = "Materia no encontrada", content = @Content)
        })
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        @DeleteMapping("/{id}")
        public ResponseEntity<Void> eliminar(@PathVariable Long id) {
                materiaService.eliminarMateria(id);
                return ResponseEntity.noContent().build();
        }
}
