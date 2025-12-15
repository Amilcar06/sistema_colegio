package com.unidadeducativa.academia.grado.controller;

import com.unidadeducativa.academia.grado.dto.GradoRequestDTO;
import com.unidadeducativa.academia.grado.dto.GradoResponseDTO;
import com.unidadeducativa.academia.grado.dto.GradoUpdateDTO;
import com.unidadeducativa.shared.enums.TipoNivel;
import com.unidadeducativa.academia.grado.service.IGradoService;
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
@RequestMapping("/api/grados")
@RequiredArgsConstructor
@Tag(name = "Grado Académico", description = "Operaciones relacionadas con grados académicos")
public class GradoController {

        private final IGradoService gradoService;

        // ---------------------------
        // REGISTRAR GRADO
        // ---------------------------
        @Operation(summary = "Registrar nuevo grado", description = "Crea un nuevo grado académico.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Grado registrado correctamente", content = @Content(schema = @Schema(implementation = GradoResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Error de validación o duplicado")
        })
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        @PostMapping
        public ResponseEntity<GradoResponseDTO> registrar(@Valid @RequestBody GradoRequestDTO dto) {
                return ResponseEntity.ok(gradoService.registrar(dto));
        }

        // ---------------------------
        // LISTAR TODOS LOS GRADOS
        // ---------------------------
        @Operation(summary = "Listar todos los grados", description = "Devuelve una lista con todos los grados académicos.")
        @ApiResponse(responseCode = "200", description = "Grados listados correctamente", content = @Content(array = @ArraySchema(schema = @Schema(implementation = GradoResponseDTO.class))))
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR')")
        @GetMapping
        public ResponseEntity<List<GradoResponseDTO>> listar() {
                return ResponseEntity.ok(gradoService.listar());
        }

        // ---------------------------
        // OBTENER GRADO POR ID
        // ---------------------------
        @Operation(summary = "Obtener grado por ID", description = "Devuelve la información de un grado académico según su ID.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Grado encontrado", content = @Content(schema = @Schema(implementation = GradoResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Grado no encontrado")
        })
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR')")
        @GetMapping("/{id}")
        public ResponseEntity<GradoResponseDTO> obtenerPorId(@PathVariable Long id) {
                return ResponseEntity.ok(gradoService.obtenerPorId(id));
        }

        // ---------------------------
        // ACTUALIZAR GRADO
        // ---------------------------
        @Operation(summary = "Actualizar grado", description = "Permite modificar los datos de un grado académico.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Grado actualizado correctamente", content = @Content(schema = @Schema(implementation = GradoResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Grado no encontrado")
        })
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        @PutMapping("/{id}")
        public ResponseEntity<GradoResponseDTO> actualizar(
                        @PathVariable Long id,
                        @Valid @RequestBody GradoUpdateDTO dto) {
                return ResponseEntity.ok(gradoService.actualizar(id, dto));
        }

        // ---------------------------
        // ELIMINAR GRADO
        // ---------------------------
        @Operation(summary = "Eliminar grado", description = "Elimina un grado académico existente.")
        @ApiResponses({
                        @ApiResponse(responseCode = "204", description = "Grado eliminado correctamente"),
                        @ApiResponse(responseCode = "404", description = "Grado no encontrado")
        })
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        @DeleteMapping("/{id}")
        public ResponseEntity<Void> eliminar(@PathVariable Long id) {
                gradoService.eliminar(id);
                return ResponseEntity.noContent().build();
        }

        // ---------------------------
        // FILTRAR POR NIVEL
        // ---------------------------
        @Operation(summary = "Filtrar grados por nivel", description = "Devuelve una lista de grados según el nivel académico: Inicial, Primaria o Secundaria.")
        @ApiResponse(responseCode = "200", description = "Grados filtrados correctamente", content = @Content(array = @ArraySchema(schema = @Schema(implementation = GradoResponseDTO.class))))
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR')")
        @GetMapping("/nivel/{nivel}")
        public ResponseEntity<List<GradoResponseDTO>> listarPorNivel(@PathVariable TipoNivel nivel) {
                return ResponseEntity.ok(gradoService.listarPorNivel(nivel));
        }
}
