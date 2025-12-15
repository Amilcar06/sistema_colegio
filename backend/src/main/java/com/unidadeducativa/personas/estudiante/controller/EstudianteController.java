package com.unidadeducativa.personas.estudiante.controller;

import com.unidadeducativa.personas.estudiante.dto.EstudianteRequestDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteResponseDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteUpdateDTO;
import com.unidadeducativa.personas.estudiante.service.IEstudianteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/estudiantes")
@RequiredArgsConstructor
@Tag(name = "Estudiantes", description = "Operaciones relacionadas con la gestión de estudiantes")
public class EstudianteController {

    private final IEstudianteService estudianteService;

    // ---------------------------
    // CONSULTAS
    // ---------------------------

    @Operation(
            summary = "Listar estudiantes",
            description = "Lista todos los estudiantes registrados. Puede filtrarse por estado (activo/inactivo)."
    )
    @ApiResponse(responseCode = "200", description = "Listado obtenido exitosamente",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = EstudianteResponseDTO.class)))
    )
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @GetMapping
    public ResponseEntity<List<EstudianteResponseDTO>> listar(
            @Parameter(description = "Filtrar por estado (true = activos, false = inactivos)")
            @RequestParam(required = false) Boolean activo) {
        return ResponseEntity.ok(estudianteService.listarEstudiantes(activo));
    }

    @Operation(summary = "Obtener estudiante por ID", description = "Devuelve los datos completos de un estudiante según su ID. Acceso solo para DIRECTOR o SECRETARIA.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estudiante encontrado",
                    content = @Content(schema = @Schema(implementation = EstudianteResponseDTO.class))),
            @ApiResponse(responseCode = "403", description = "Acceso denegado"),
            @ApiResponse(responseCode = "404", description = "Estudiante no encontrado")
    })
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_ALUMNO')")
    @GetMapping("/{id}")
    public ResponseEntity<EstudianteResponseDTO> obtenerPorId(
            @Parameter(description = "ID del estudiante") @PathVariable Long id,
            Authentication authentication) {
        EstudianteResponseDTO dto = estudianteService.obtenerPorId(id);

        // Verificación extra si el que accede es un estudiante
        if (authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ALUMNO"))) {
            if (!dto.getCorreo().equalsIgnoreCase(authentication.getName())) {
                return ResponseEntity.status(403).build();
            }
        }

        return ResponseEntity.ok(dto);
    }

    @Operation(summary = "Obtener perfil del estudiante autenticado", description = "Devuelve los datos del estudiante autenticado mediante JWT.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Perfil del estudiante obtenido correctamente",
                    content = @Content(schema = @Schema(implementation = EstudianteResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "Estudiante no encontrado")
    })
    @PreAuthorize("hasRole('ROLE_ALUMNO')")
    @GetMapping("/mi-perfil")
    public ResponseEntity<EstudianteResponseDTO> obtenerPerfil(Authentication auth) {
        return ResponseEntity.ok(estudianteService.obtenerPorCorreo(auth.getName()));
    }

    // ---------------------------
    // REGISTRO
    // ---------------------------

    @Operation(summary = "Registro completo de estudiante", description = "Crea un nuevo estudiante junto a su usuario.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estudiante registrado exitosamente",
                    content = @Content(schema = @Schema(implementation = EstudianteResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos o duplicados")
    })
    @PreAuthorize("hasAnyRole('ROLE_SECRETARIA')")
    @PostMapping("/registro")
    public ResponseEntity<EstudianteResponseDTO> registrar(
            @RequestBody @Valid EstudianteRequestDTO dto) {
        return ResponseEntity.ok(estudianteService.registrarEstudianteCompleto(dto));
    }

    // ---------------------------
    // ACTUALIZACIÓN
    // ---------------------------

    @Operation(summary = "Actualizar estudiante por ID", description = "Modifica los datos de un estudiante existente.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estudiante actualizado exitosamente",
                    content = @Content(schema = @Schema(implementation = EstudianteResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos"),
            @ApiResponse(responseCode = "404", description = "Estudiante no encontrado")
    })
    @PreAuthorize("hasAnyRole('ROLE_SECRETARIA')")
    @PutMapping("/{id}")
    public ResponseEntity<EstudianteResponseDTO> actualizar(
            @Parameter(description = "ID del estudiante a actualizar") @PathVariable Long id,
            @RequestBody @Valid EstudianteUpdateDTO dto) {
        return ResponseEntity.ok(estudianteService.actualizarEstudiante(id, dto));
    }

    @Operation(summary = "Editar perfil del estudiante autenticado", description = "Permite a un estudiante actualizar sus propios datos.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Perfil actualizado correctamente",
                    content = @Content(schema = @Schema(implementation = EstudianteResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos"),
            @ApiResponse(responseCode = "404", description = "Usuario o estudiante no encontrado")
    })
    @PreAuthorize("hasRole('ROLE_ALUMNO')")
    @PutMapping("/mi-perfil")
    public ResponseEntity<EstudianteResponseDTO> actualizarMiPerfil(
            Authentication auth,
            @RequestBody @Valid EstudianteUpdateDTO dto) {
        return ResponseEntity.ok(estudianteService.actualizarPorCorreo(auth.getName(), dto));
    }

    // ---------------------------
    // ELIMINACIÓN
    // ---------------------------

    @Operation(summary = "Eliminar un estudiante por ID", description = "Elimina completamente un estudiante y su usuario asociado.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Estudiante eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Estudiante no encontrado")
    })
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(
            @Parameter(description = "ID del estudiante a eliminar") @PathVariable Long id) {
        estudianteService.eliminarEstudiante(id);
        return ResponseEntity.noContent().build();
    }

    // ---------------------------
    // ESTADO (activar/desactivar)
    // ---------------------------

    @Operation(summary = "Activar estudiante", description = "Habilita el acceso del estudiante al sistema.")
    @ApiResponse(responseCode = "204", description = "Estudiante activado correctamente")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @PutMapping("/{id}/activar")
    public ResponseEntity<Void> activar(
            @Parameter(description = "ID del estudiante a activar") @PathVariable Long id) {
        estudianteService.cambiarEstadoEstudiante(id, true);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Desactivar estudiante", description = "Inhabilita el acceso del estudiante al sistema.")
    @ApiResponse(responseCode = "204", description = "Estudiante desactivado correctamente")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
    @PutMapping("/{id}/desactivar")
    public ResponseEntity<Void> desactivar(
            @Parameter(description = "ID del estudiante a desactivar") @PathVariable Long id) {
        estudianteService.cambiarEstadoEstudiante(id, false);
        return ResponseEntity.noContent().build();
    }
}