package com.unidadeducativa.personas.director.controller;

import com.unidadeducativa.personas.director.dto.DirectorRequestDTO;
import com.unidadeducativa.personas.director.dto.DirectorResponseDTO;
import com.unidadeducativa.personas.director.dto.DirectorUpdateDTO;
import com.unidadeducativa.personas.director.service.IDirectorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/directores")
@RequiredArgsConstructor
@Tag(name = "Directores", description = "Operaciones relacionadas con la gestión de directores")
public class DirectorController {

        private final IDirectorService directorService;

        // ---------------------------
        // CONSULTAS
        // ---------------------------

        @Operation(summary = "Listar directores", description = "Devuelve todos los directores registrados.")
        @ApiResponse(responseCode = "200", description = "Directores listados correctamente", content = @Content(array = @ArraySchema(schema = @Schema(implementation = DirectorResponseDTO.class))))
        // @PreAuthorize("hasRole('ROLE_ADMIN')")
        @GetMapping
        public ResponseEntity<List<DirectorResponseDTO>> listar() {
                return ResponseEntity.ok(directorService.listarDirectores());
        }

        @Operation(summary = "Obtener director por ID", description = "Devuelve los datos del director por su ID.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Director encontrado", content = @Content(schema = @Schema(implementation = DirectorResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Director no encontrado")
        })
        // @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        @GetMapping("/{id}")
        public ResponseEntity<DirectorResponseDTO> obtenerPorId(@PathVariable Long id, Authentication authentication) {
                DirectorResponseDTO dto = directorService.obtenerPorId(id);

                // Verificación extra si el que accede es un estudiante
                if (authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_DIRECTOR"))) {
                        if (!dto.getCorreo().equalsIgnoreCase(authentication.getName())) {
                                return ResponseEntity.status(403).build();
                        }
                }
                return ResponseEntity.ok(dto);
        }

        @Operation(summary = "Obtener perfil del director autenticado", description = "Devuelve los datos del director autenticado mediante JWT.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Perfil obtenido correctamente", content = @Content(schema = @Schema(implementation = DirectorResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Director no encontrado")
        })
        // @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @GetMapping("/mi-perfil")
        public ResponseEntity<DirectorResponseDTO> obtenerPerfil(Authentication authentication) {
                String correo = authentication.getName();
                return ResponseEntity.ok(directorService.obtenerPorCorreo(correo));
        }

        // ---------------------------
        // REGISTRO
        // ---------------------------

        @Operation(summary = "Registrar un nuevo director", description = "Crea un nuevo director con su respectiva cuenta de usuario con rol DIRECTOR.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Director registrado exitosamente", content = @Content(schema = @Schema(implementation = DirectorResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos o CI/correo duplicado")
        })
        // @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PostMapping("/registro")
        public ResponseEntity<DirectorResponseDTO> registrar(
                        @Valid @RequestBody DirectorRequestDTO dto) {
                return ResponseEntity.ok(directorService.registrarDirector(dto));
        }

        // ---------------------------
        // ACTUALIZACIÓN
        // ---------------------------

        @Operation(summary = "Actualizar un director por ID", description = "Actualiza los datos del director. Solo accesible por el ADMIN.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Director actualizado exitosamente", content = @Content(schema = @Schema(implementation = DirectorResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos"),
                        @ApiResponse(responseCode = "404", description = "Director no encontrado")
        })
        // @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PutMapping("/{id}")
        public ResponseEntity<DirectorResponseDTO> actualizar(
                        @PathVariable Long id,
                        @Valid @RequestBody DirectorUpdateDTO dto) {
                return ResponseEntity.ok(directorService.actualizarDirector(id, dto));
        }

        @Operation(summary = "Actualizar perfil del director autenticado", description = "Permite a un director modificar sus propios datos.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Perfil actualizado correctamente", content = @Content(schema = @Schema(implementation = DirectorResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos")
        })
        // @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/mi-perfil")
        public ResponseEntity<DirectorResponseDTO> actualizarMiPerfil(
                        Authentication authentication,
                        @Valid @RequestBody DirectorUpdateDTO dto) {
                String correo = authentication.getName();
                return ResponseEntity.ok(directorService.actualizarPorCorreo(correo, dto));
        }

        // ---------------------------
        // ELIMINACIÓN
        // ---------------------------

        @Operation(summary = "Eliminar un director", description = "Elimina el director y su usuario asociado del sistema.")
        @ApiResponses({
                        @ApiResponse(responseCode = "204", description = "Director eliminado correctamente"),
                        @ApiResponse(responseCode = "404", description = "Director no encontrado")
        })
        // @PreAuthorize("hasRole('ROLE_ADMIN')")
        @DeleteMapping("/{id}")
        public ResponseEntity<Void> eliminar(@PathVariable Long id) {
                directorService.eliminarDirector(id);
                return ResponseEntity.noContent().build();
        }

        // ---------------------------
        // ESTADO (activar/desactivar)
        // ---------------------------

        @Operation(summary = "Activar director", description = "Activa al director y su cuenta de usuario.")
        // @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PutMapping("/{id}/activar")
        public ResponseEntity<Void> activar(@PathVariable Long id) {
                directorService.cambiarEstadoDirector(id, true);
                return ResponseEntity.noContent().build();
        }

        @Operation(summary = "Desactivar director", description = "Desactiva al director y su cuenta de usuario.")
        // @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PutMapping("/{id}/desactivar")
        public ResponseEntity<Void> desactivar(@PathVariable Long id) {
                directorService.cambiarEstadoDirector(id, false);
                return ResponseEntity.noContent().build();
        }

}
