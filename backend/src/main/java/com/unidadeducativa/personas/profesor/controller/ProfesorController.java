package com.unidadeducativa.personas.profesor.controller;

import com.unidadeducativa.personas.profesor.dto.ProfesorRequestDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorResponseDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorUpdateDTO;
import com.unidadeducativa.personas.profesor.service.IProfesorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;

@RestController
@RequestMapping("/api/profesores")
@RequiredArgsConstructor
@Tag(name = "Profesores", description = "Operaciones relacionadas con la gestión de profesores")
public class ProfesorController {

        private final IProfesorService profesorService;

        // ---------------------------
        // CONSULTAS
        // ---------------------------

        @Operation(summary = "Listar profesores", description = "Lista todos los profesores registrados, con opción de filtrar por estado activo/inactivo.")
        @ApiResponse(responseCode = "200", description = "Profesores listados correctamente", content = @Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = ProfesorResponseDTO.class))))
        @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
        @GetMapping
        public ResponseEntity<Page<ProfesorResponseDTO>> listarProfesores(
                        @RequestParam(required = false) Boolean activo, Pageable pageable) {
                return ResponseEntity.ok(profesorService.listarProfesores(activo, pageable));
        }

        @Operation(summary = "Obtener profesor por ID", description = "Devuelve los datos de un profesor por su ID. Acceso solo para DIRECTOR o SECRETARIA.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Profesor encontrado", content = @Content(schema = @Schema(implementation = ProfesorResponseDTO.class))),
                        @ApiResponse(responseCode = "403", description = "Acceso denegado"),
                        @ApiResponse(responseCode = "404", description = "Profesor no encontrado")
        })
        @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR')")
        @GetMapping("/{id}")
        public ResponseEntity<ProfesorResponseDTO> obtenerPorId(
                        @PathVariable Long id,
                        Authentication authentication) {
                ProfesorResponseDTO dto = profesorService.obtenerPorId(id);

                // Verificación extra si el que accede es un profesor
                if (authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_PROFESOR"))) {
                        if (!dto.getCorreo().equalsIgnoreCase(authentication.getName())) {
                                return ResponseEntity.status(403).build();
                        }
                }

                return ResponseEntity.ok(dto);
        }

        @Operation(summary = "Obtener perfil del profesor autenticado", description = "Devuelve los datos del estudiante autenticado mediante JWT.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Perfil del profesor obtenido correctamente", content = @Content(schema = @Schema(implementation = ProfesorResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Profesor no encontrado")
        })
        @PreAuthorize("hasRole('ROLE_PROFESOR')")
        @GetMapping("/mi-perfil")
        public ResponseEntity<ProfesorResponseDTO> obtenerPerfil(Authentication authentication) {
                String correo = authentication.getName();
                return ResponseEntity.ok(profesorService.obtenerPorCorreo(correo));
        }

        @Operation(summary = "Obtener estadísticas para Dashboard Profesor", description = "Totales de cursos, estudiantes y clases de hoy.")
        @PreAuthorize("hasRole('ROLE_PROFESOR')")
        @GetMapping("/dashboard-stats")
        public ResponseEntity<com.unidadeducativa.personas.profesor.dto.DashboardProfesorStatsDTO> getDashboardStats(
                        Authentication authentication) {
                String correo = authentication.getName();
                return ResponseEntity.ok(profesorService.getDashboardStats(correo));
        }

        // ---------------------------
        // REGISTRO
        // ---------------------------

        @Operation(summary = "Registrar un nuevo profesor", description = "Crea un nuevo profesor con su respectiva cuenta de usuario con rol PROFESOR.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Profesor registrado exitosamente", content = @Content(schema = @Schema(implementation = ProfesorResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos o CI/correo duplicado")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PostMapping("/registro")
        public ResponseEntity<ProfesorResponseDTO> registroCompleto(
                        @Valid @RequestBody ProfesorRequestDTO dto) {
                return ResponseEntity.ok(profesorService.registrarProfesorCompleto(dto));
        }

        // ---------------------------
        // ACTUALIZACIÓN
        // ---------------------------

        @Operation(summary = "Actualizar un profesor por ID", description = "Actualiza los datos del profesor. Solo accesible por el director.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Profesor actualizado exitosamente", content = @Content(schema = @Schema(implementation = ProfesorResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos"),
                        @ApiResponse(responseCode = "404", description = "Profesor no encontrado")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/{id}")
        public ResponseEntity<ProfesorResponseDTO> actualizar(
                        @PathVariable Long id,
                        @Valid @RequestBody ProfesorUpdateDTO requestDTO) {
                return ResponseEntity.ok(profesorService.actualizarProfesor(id, requestDTO));
        }

        @Operation(summary = "Editar perfil del profesor autenticado", description = "Permite a un profesor modificar sus propios datos.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Perfil actualizado correctamente", content = @Content(schema = @Schema(implementation = ProfesorResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos")
        })
        @PreAuthorize("hasRole('ROLE_PROFESOR')")
        @PutMapping("/mi-perfil")
        public ResponseEntity<ProfesorResponseDTO> actualizarMiPerfil(
                        Authentication authentication,
                        @Valid @RequestBody ProfesorUpdateDTO dto) {
                String correo = authentication.getName();
                return ResponseEntity.ok(profesorService.actualizarPorCorreo(correo, dto));
        }

        // ---------------------------
        // ELIMINACIÓN
        // ---------------------------

        @Operation(summary = "Eliminar un profesor", description = "Elimina el profesor y su usuario asociado del sistema.")
        @ApiResponses({
                        @ApiResponse(responseCode = "204", description = "Profesor eliminado correctamente"),
                        @ApiResponse(responseCode = "404", description = "Profesor no encontrado")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @DeleteMapping("/{id}")
        public ResponseEntity<Void> eliminarProfesor(@PathVariable Long id) {
                profesorService.eliminarProfesor(id);
                return ResponseEntity.noContent().build();
        }

        // ---------------------------
        // ESTADO (activar/desactivar)
        // ---------------------------

        @Operation(summary = "Activar profesor", description = "Activa al profesor y su cuenta de usuario.")
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/{id}/activar")
        public ResponseEntity<Void> activarProfesor(@PathVariable Long id) {
                profesorService.cambiarEstadoProfesor(id, true);
                return ResponseEntity.noContent().build();
        }

        @Operation(summary = "Desactivar profesor", description = "Desactiva al profesor y su cuenta de usuario.")
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/{id}/desactivar")
        public ResponseEntity<Void> desactivarProfesor(@PathVariable Long id) {
                profesorService.cambiarEstadoProfesor(id, false);
                return ResponseEntity.noContent().build();
        }

}
