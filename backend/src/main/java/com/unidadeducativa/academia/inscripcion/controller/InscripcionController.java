package com.unidadeducativa.academia.inscripcion.controller;

import com.unidadeducativa.academia.inscripcion.dto.InscripcionEstadoRequestDTO;
import com.unidadeducativa.academia.inscripcion.dto.InscripcionRequestDTO;
import com.unidadeducativa.academia.inscripcion.dto.InscripcionResponseDTO;
import com.unidadeducativa.academia.inscripcion.service.IInscripcionService;
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
@RequestMapping("/api/inscripciones")
@RequiredArgsConstructor
@Tag(name = "Inscripción", description = "Operaciones relacionadas con inscripciones académicas")
public class InscripcionController {

    private final IInscripcionService service;

    // -------------------------------
    // REGISTRAR NUEVA INSCRIPCIÓN
    // -------------------------------
    @Operation(summary = "Registrar inscripción",
            description = "Registra una nueva inscripción para un estudiante en la gestión académica activa.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Inscripción registrada correctamente",
                    content = @Content(schema = @Schema(implementation = InscripcionResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Error de validación o reglas del negocio"),
            @ApiResponse(responseCode = "404", description = "Estudiante o curso no encontrados")
    })
    @PreAuthorize("hasRole('ROLE_SECRETARIA')")
    @PostMapping
    public ResponseEntity<InscripcionResponseDTO> registrar(
            @Valid @RequestBody InscripcionRequestDTO dto) {
        return ResponseEntity.ok(service.registrar(dto));
    }

    // ------------------------------------------
    // LISTAR INSCRIPCIONES POR ESTUDIANTE
    // ------------------------------------------
    @Operation(summary = "Listar inscripciones de un estudiante",
            description = "Devuelve todas las inscripciones realizadas por el estudiante con el ID proporcionado.")
    @ApiResponse(responseCode = "200", description = "Inscripciones listadas correctamente",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = InscripcionResponseDTO.class))))
    @PreAuthorize("hasAnyRole('ROLE_SECRETARIA', 'ROLE_ESTUDIANTE')")
    @GetMapping("/estudiante/{id}")
    public ResponseEntity<List<InscripcionResponseDTO>> porEstudiante(@PathVariable Long id) {
        return ResponseEntity.ok(service.listarPorEstudiante(id));
    }

    // ------------------------------------------
    // LISTAR INSCRIPCIONES POR CURSO
    // ------------------------------------------
    @Operation(summary = "Listar inscripciones por curso",
            description = "Devuelve todas las inscripciones al curso con el ID especificado.")
    @ApiResponse(responseCode = "200", description = "Inscripciones listadas correctamente",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = InscripcionResponseDTO.class))))
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @GetMapping("/curso/{id}")
    public ResponseEntity<List<InscripcionResponseDTO>> porCurso(@PathVariable Long id) {
        return ResponseEntity.ok(service.listarPorCurso(id));
    }

    // ------------------------------------------
    // LISTAR INSCRIPCIONES POR GESTIÓN
    // ------------------------------------------
    @Operation(summary = "Listar inscripciones por gestión académica",
            description = "Devuelve todas las inscripciones registradas para una gestión específica.")
    @ApiResponse(responseCode = "200", description = "Inscripciones listadas correctamente",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = InscripcionResponseDTO.class))))
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @GetMapping("/gestion/{id}")
    public ResponseEntity<List<InscripcionResponseDTO>> porGestion(@PathVariable Long id) {
        return ResponseEntity.ok(service.listarPorGestion(id));
    }

    // ------------------------------------------
    // LISTAR ESTUDIANTES INSCRITOS A UN CURSO
    // ------------------------------------------
    @Operation(summary = "Listar estudiantes inscritos en un curso",
            description = "Devuelve todos los estudiantes inscritos en el curso con el ID especificado.")
    @ApiResponse(responseCode = "200", description = "Estudiantes listados correctamente",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = InscripcionResponseDTO.class))))
    @PreAuthorize("hasAnyRole('ROLE_PROFESOR', 'ROLE_SECRETARIA', 'ROLE_DIRECTOR')")
    @GetMapping("/curso/{id}/estudiantes")
    public ResponseEntity<List<InscripcionResponseDTO>> estudiantesPorCurso(@PathVariable Long id) {
        return ResponseEntity.ok(service.listarEstudiantesPorCurso(id));
    }

    // ------------------------------------------
    // ACTUALIZAR ESTADO DE INSCRIPCIONES
    // ------------------------------------------
    @PutMapping("/estado")
    @PreAuthorize("hasAnyRole('SECRETARIA', 'DIRECTOR')")
    public ResponseEntity<?> cambiarEstadoInscripcion(@RequestBody @Valid InscripcionEstadoRequestDTO dto) {
        service.cambiarEstadoInscripcion(dto);
        return ResponseEntity.ok("Estado de inscripción actualizado correctamente.");
    }
}
