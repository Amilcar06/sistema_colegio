package com.unidadeducativa.academia.asignaciondocente.controller;

import com.unidadeducativa.academia.asignaciondocente.dto.AsignacionDocenteRequestDTO;
import com.unidadeducativa.academia.asignaciondocente.dto.AsignacionDocenteResponseDTO;
import com.unidadeducativa.academia.asignaciondocente.service.IAsignacionDocenteService;
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
@RequestMapping("/api/asignaciones")
@RequiredArgsConstructor
@Tag(name = "Asignación Docente", description = "Gestión de asignación de curso-materia-profesor")
public class AsignacionDocenteController {

        private final IAsignacionDocenteService service;

        // ---------------------------
        // CREAR ASIGNACIÓN
        // ---------------------------

        @Operation(summary = "Asignar curso-materia-profesor", description = "Crea una nueva asignación docente para un curso, materia y gestión específica.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Asignación creada correctamente", content = @Content(schema = @Schema(implementation = AsignacionDocenteResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Asignación ya existente o datos inválidos")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PostMapping
        public ResponseEntity<AsignacionDocenteResponseDTO> crear(@Valid @RequestBody AsignacionDocenteRequestDTO dto) {
                return ResponseEntity.ok(service.crear(dto));
        }

        // ---------------------------
        // ACTUALIZAR ASIGNACIÓN
        // ---------------------------

        @Operation(summary = "Editar asignación", description = "Permite actualizar la información de una asignación docente existente.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Asignación actualizada correctamente", content = @Content(schema = @Schema(implementation = AsignacionDocenteResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Asignación no encontrada")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/{id}")
        public ResponseEntity<AsignacionDocenteResponseDTO> actualizar(
                        @PathVariable Long id,
                        @Valid @RequestBody AsignacionDocenteRequestDTO dto) {
                return ResponseEntity.ok(service.actualizar(id, dto));
        }

        // ---------------------------
        // ELIMINAR ASIGNACIÓN
        // ---------------------------

        @Operation(summary = "Eliminar asignación", description = "Elimina una asignación docente existente por ID.")
        @ApiResponses({
                        @ApiResponse(responseCode = "204", description = "Asignación eliminada correctamente"),
                        @ApiResponse(responseCode = "404", description = "Asignación no encontrada")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @DeleteMapping("/{id}")
        public ResponseEntity<Void> eliminar(@PathVariable Long id) {
                service.eliminar(id);
                return ResponseEntity.noContent().build();
        }

        // ---------------------------
        // LISTAR POR CURSO
        // ---------------------------

        @Operation(summary = "Listar asignaciones por curso", description = "Devuelve todas las asignaciones docentes registradas para un curso específico.")
        @ApiResponse(responseCode = "200", description = "Lista de asignaciones", content = @Content(array = @ArraySchema(schema = @Schema(implementation = AsignacionDocenteResponseDTO.class))))
        @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_PROFESOR')")
        @GetMapping("/curso/{idCurso}")
        public ResponseEntity<List<AsignacionDocenteResponseDTO>> listarPorCurso(@PathVariable Long idCurso) {
                return ResponseEntity.ok(service.listarPorCurso(idCurso));
        }

        // ---------------------------
        // LISTAR POR PROFESOR
        // ---------------------------

        @Operation(summary = "Listar asignaciones por profesor", description = "Devuelve todas las asignaciones de materias y cursos asignadas a un profesor específico.")
        @ApiResponse(responseCode = "200", description = "Lista de asignaciones", content = @Content(array = @ArraySchema(schema = @Schema(implementation = AsignacionDocenteResponseDTO.class))))
        @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_PROFESOR')")
        @GetMapping("/profesor/{idProfesor}")
        public ResponseEntity<List<AsignacionDocenteResponseDTO>> listarPorProfesor(@PathVariable Long idProfesor) {
                return ResponseEntity.ok(service.listarPorProfesor(idProfesor));
        }

        // ---------------------------
        // LISTAR MATERIAS DE UN CURSO
        // ---------------------------

        @Operation(summary = "Listar materias asignadas a un curso", description = "Obtiene la lista de materias que han sido asignadas a un curso determinado.")
        @ApiResponse(responseCode = "200", description = "Lista de materias asignadas", content = @Content(array = @ArraySchema(schema = @Schema(implementation = AsignacionDocenteResponseDTO.class))))
        @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_PROFESOR')")
        @GetMapping("/curso/{idCurso}/materias")
        public ResponseEntity<List<AsignacionDocenteResponseDTO>> listarMateriasAsignadasPorCurso(
                        @PathVariable Long idCurso) {
                return ResponseEntity.ok(service.listarMateriasAsignadasPorCurso(idCurso));
        }

        @Operation(summary = "Obtener mis cursos asignados", description = "Devuelve las asignaciones del profesor autenticado.")
        @PreAuthorize("hasRole('ROLE_PROFESOR')")
        @GetMapping("/mis-cursos")
        public ResponseEntity<List<AsignacionDocenteResponseDTO>> listarMisCursos(
                        org.springframework.security.core.Authentication authentication) {
                return ResponseEntity.ok(service.listarPorUsuario(authentication.getName()));
        }
}
