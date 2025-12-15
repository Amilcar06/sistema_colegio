package com.unidadeducativa.personas.secretaria.controller;

import com.unidadeducativa.personas.secretaria.dto.SecretariaRequestDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaResponseDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaUpdateDTO;
import com.unidadeducativa.personas.secretaria.service.ISecretariaService;
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

import java.util.List;

@RestController
@RequestMapping("/api/secretarias")
@RequiredArgsConstructor
@Tag(name = "Secretarias", description = "Operaciones relacionadas con la gestión de secretarias")
public class SecretariaController {

        private final ISecretariaService secretariaService;

        // ---------------------------
        // CONSULTAS
        // ---------------------------

        @Operation(summary = "Listar secretarias", description = "Devuelve todas las secretarias registradas.")
        @ApiResponse(responseCode = "200", description = "Secretarias listadas correctamente", content = @Content(array = @ArraySchema(schema = @Schema(implementation = SecretariaResponseDTO.class))))
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @GetMapping
        public ResponseEntity<List<SecretariaResponseDTO>> listar() {
                return ResponseEntity.ok(secretariaService.listarSecretarias());
        }

        @Operation(summary = "Obtener secretaria por ID", description = "Devuelve los datos de la secretaria por su ID.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Secretaria encontrada", content = @Content(schema = @Schema(implementation = SecretariaResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Secretaria no encontrada")
        })
        @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_SECRETARIA')")
        @GetMapping("/{id}")
        public ResponseEntity<SecretariaResponseDTO> obtenerPorId(@PathVariable Long id,
                        Authentication authentication) {
                SecretariaResponseDTO dto = secretariaService.obtenerPorId(id);

                // Verificación extra si el que accede es una secretaria
                if (authentication.getAuthorities().stream()
                                .anyMatch(a -> a.getAuthority().equals("ROLE_SECRETARIA"))) {
                        if (!dto.getCorreo().equalsIgnoreCase(authentication.getName())) {
                                return ResponseEntity.status(403).build();
                        }
                }
                return ResponseEntity.ok(dto);
        }

        @Operation(summary = "Obtener perfil de la secretaria autenticada", description = "Devuelve los datos de la secretaria autenticada mediante JWT.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Perfil obtenido correctamente", content = @Content(schema = @Schema(implementation = SecretariaResponseDTO.class))),
                        @ApiResponse(responseCode = "404", description = "Secretaria no encontrada")
        })
        @PreAuthorize("hasRole('ROLE_SECRETARIA')")
        @GetMapping("/mi-perfil")
        public ResponseEntity<SecretariaResponseDTO> obtenerPerfil(Authentication authentication) {
                String correo = authentication.getName();
                return ResponseEntity.ok(secretariaService.obtenerPorCorreo(correo));
        }

        // ---------------------------
        // REGISTRO
        // ---------------------------

        @Operation(summary = "Registrar una nueva secretaria", description = "Crea una nueva secretaria con su respectiva cuenta de usuario con rol SECRETARIA.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Secretaria registrada exitosamente", content = @Content(schema = @Schema(implementation = SecretariaResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos o CI/correo duplicado")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PostMapping("/registro")
        public ResponseEntity<SecretariaResponseDTO> registrar(
                        @Valid @RequestBody SecretariaRequestDTO dto) {
                return ResponseEntity.ok(secretariaService.registrarSecretaria(dto));
        }

        // ---------------------------
        // ACTUALIZACIÓN
        // ---------------------------

        @Operation(summary = "Actualizar una secretaria por ID", description = "Actualiza los datos de la secretaria. Solo accesible por el ADMIN.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Secretaria actualizada exitosamente", content = @Content(schema = @Schema(implementation = SecretariaResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos"),
                        @ApiResponse(responseCode = "404", description = "Secretaria no encontrada")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/{id}")
        public ResponseEntity<SecretariaResponseDTO> actualizar(
                        @PathVariable Long id,
                        @Valid @RequestBody SecretariaUpdateDTO dto) {
                return ResponseEntity.ok(secretariaService.actualizarSecretaria(id, dto));
        }

        @Operation(summary = "Actualizar perfil de la secretaria autenticada", description = "Permite a una secretaria modificar sus propios datos.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Perfil actualizado correctamente", content = @Content(schema = @Schema(implementation = SecretariaResponseDTO.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos")
        })
        @PreAuthorize("hasRole('ROLE_SECRETARIA')")
        @PutMapping("/mi-perfil")
        public ResponseEntity<SecretariaResponseDTO> actualizarMiPerfil(
                        Authentication authentication,
                        @Valid @RequestBody SecretariaUpdateDTO dto) {
                String correo = authentication.getName();
                return ResponseEntity.ok(secretariaService.actualizarPorCorreo(correo, dto));
        }

        // ---------------------------
        // ELIMINACIÓN
        // ---------------------------

        @Operation(summary = "Eliminar una secretaria", description = "Elimina la secretaria y su usuario asociado del sistema.")
        @ApiResponses({
                        @ApiResponse(responseCode = "204", description = "Secretaria eliminada correctamente"),
                        @ApiResponse(responseCode = "404", description = "Secretaria no encontrada")
        })
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @DeleteMapping("/{id}")
        public ResponseEntity<Void> eliminar(@PathVariable Long id) {
                secretariaService.eliminarSecretaria(id);
                return ResponseEntity.noContent().build();
        }

        // ---------------------------
        // ESTADO (activar/desactivar)
        // ---------------------------

        @Operation(summary = "Activar secretaria", description = "Activa a la secretaria y su cuenta de usuario.")
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/{id}/activar")
        public ResponseEntity<Void> activar(@PathVariable Long id) {
                secretariaService.cambiarEstadoSecretaria(id, true);
                return ResponseEntity.noContent().build();
        }

        @Operation(summary = "Desactivar secretaria", description = "Desactiva a la secretaria y su cuenta de usuario.")
        @PreAuthorize("hasRole('ROLE_DIRECTOR')")
        @PutMapping("/{id}/desactivar")
        public ResponseEntity<Void> desactivar(@PathVariable Long id) {
                secretariaService.cambiarEstadoSecretaria(id, false);
                return ResponseEntity.noContent().build();
        }
}