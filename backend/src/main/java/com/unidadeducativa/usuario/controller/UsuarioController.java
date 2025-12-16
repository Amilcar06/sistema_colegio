package com.unidadeducativa.usuario.controller;

import com.unidadeducativa.usuario.dto.*;
import com.unidadeducativa.usuario.service.IUsuarioService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
@Tag(name = "Usuarios", description = "Operaciones relacionadas a la gestión de usuarios")
public class UsuarioController {

        private final IUsuarioService usuarioService;

        // ======================================
        // ENDPOINTS ESPECIFICOS FRONTEND (DIRECTOR)
        // ======================================

        @GetMapping("/secretarias")
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        public ResponseEntity<List<UsuarioResponseDTO>> listarUsuariosSecretarias() {
                return ResponseEntity.ok(usuarioService.listarUsuariosSecretarias());
        }

        @PostMapping("/registro-director")
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        public ResponseEntity<UsuarioResponseDTO> registrarDirector(@Valid @RequestBody UsuarioSinRolRequestDTO dto) {
                return ResponseEntity.ok(usuarioService.registrarDirector(dto));
        }

        @PostMapping("/registro-secretaria")
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR')")
        public ResponseEntity<UsuarioResponseDTO> registrarSecretaria(@Valid @RequestBody UsuarioSinRolRequestDTO dto) {
                return ResponseEntity.ok(usuarioService.registrarSecretaria(dto));
        }

        // ======================================
        // CRUD BÁSICO DE USUARIOS (ADMIN)
        // ======================================

        @Operation(summary = "Listar todos los usuarios", description = "Devuelve una lista con todos los usuarios registrados en el sistema.")
        @ApiResponse(responseCode = "200", description = "Lista de usuarios obtenida correctamente")
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @GetMapping
        public ResponseEntity<List<UsuarioResponseDTO>> listarTodos() {
                return ResponseEntity.ok(usuarioService.listarUsuarios());
        }

        @Operation(summary = "Obtener un usuario por ID", description = "Recupera los datos de un usuario a partir de su ID.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Usuario encontrado"),
                        @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
        })
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @GetMapping("/{id}")
        public ResponseEntity<UsuarioResponseDTO> obtenerPorId(
                        @PathVariable Long id) {
                return ResponseEntity.ok(usuarioService.obtenerPorId(id));
        }

        @Operation(summary = "Crear un nuevo usuario", description = "Registra un nuevo usuario con los datos proporcionados.")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Usuario creado correctamente"),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos o correo ya registrado")
        })
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PostMapping
        public ResponseEntity<UsuarioResponseDTO> crearUsuario(
                        @Valid @RequestBody UsuarioRequestDTO dto) {
                return ResponseEntity.ok(usuarioService.crearUsuario(dto));
        }

        @Operation(summary = "Actualizar un usuario existente", description = "Actualiza los datos de un usuario registrado, identificado por su ID.")
        @ApiResponse(responseCode = "200", description = "Usuario actualizado correctamente")
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PutMapping("/{id}")
        public ResponseEntity<UsuarioResponseDTO> actualizarUsuario(
                        @PathVariable Long id,
                        @Valid @RequestBody UsuarioUpdateDTO dto) {
                return ResponseEntity.ok(usuarioService.actualizarUsuario(id, dto));
        }

        @Operation(summary = "Eliminar un usuario por ID", description = "Elimina un usuario de la base de datos de forma permanente.")
        @ApiResponse(responseCode = "204", description = "Usuario eliminado correctamente")
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @DeleteMapping("/{id}")
        public ResponseEntity<Void> eliminarUsuario(
                        @PathVariable Long id) {
                usuarioService.eliminarUsuario(id);
                return ResponseEntity.noContent().build();
        }

        // ======================================
        // USUARIO ACTUAL (AUTENTICADO)
        // ======================================

        @Operation(summary = "Obtener perfil del usuario autenticado", description = "Devuelve los datos del usuario que ha iniciado sesión con JWT.")
        @ApiResponse(responseCode = "200", description = "Datos del usuario autenticado obtenidos correctamente")
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR', 'ROLE_ESTUDIANTE')")
        @GetMapping("/me")
        public ResponseEntity<UsuarioResponseDTO> obtenerUsuarioActual() {
                return ResponseEntity.ok(usuarioService.obtenerUsuarioActual());
        }

        @Operation(summary = "Actualizar perfil del usuario autenticado", description = "Permite al usuario autenticado modificar su propia información personal.")
        @ApiResponse(responseCode = "200", description = "Perfil actualizado correctamente")
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR', 'ROLE_ESTUDIANTE')")
        @PutMapping("/me")
        public ResponseEntity<UsuarioResponseDTO> actualizarPerfil(
                        @Valid @RequestBody UsuarioUpdateDTO dto) {
                return ResponseEntity.ok(usuarioService.actualizarPerfilActual(dto));
        }

        @Operation(summary = "Cambiar contraseña del usuario autenticado", description = "Permite al usuario autenticado cambiar su propia contraseña.")
        @ApiResponse(responseCode = "204", description = "Contraseña actualizada correctamente")
        @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_DIRECTOR', 'ROLE_SECRETARIA', 'ROLE_PROFESOR', 'ROLE_ESTUDIANTE')")
        @PutMapping("/me/contrasena")
        public ResponseEntity<Void> cambiarPassword(
                        @Valid @RequestBody PasswordUpdateDTO dto) {
                usuarioService.cambiarPasswordActual(dto);
                return ResponseEntity.noContent().build();
        }

        // ======================================
        // UTILITARIOS
        // ======================================

        @Operation(summary = "Buscar usuario por correo", description = "Devuelve los datos del usuario asociado al correo electrónico indicado.")
        @ApiResponse(responseCode = "200", description = "Usuario encontrado por correo")
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @GetMapping("/correo/{correo}")
        public ResponseEntity<UsuarioResponseDTO> obtenerPorCorreo(
                        @PathVariable String correo) {
                return ResponseEntity.ok(usuarioService.obtenerPorCorreo(correo));
        }

        @Operation(summary = "Activar usuario", description = "Habilita el acceso de un usuario al sistema.")
        @ApiResponse(responseCode = "204", description = "Usuario activado correctamente")
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PutMapping("/{id}/activar")
        public ResponseEntity<Void> activarUsuario(@PathVariable Long id) {
                usuarioService.cambiarEstadoUsuario(id, true);
                return ResponseEntity.noContent().build();
        }

        @Operation(summary = "Desactivar usuario", description = "Inhabilita temporalmente el acceso del usuario al sistema.")
        @ApiResponse(responseCode = "204", description = "Usuario desactivado correctamente")
        @PreAuthorize("hasRole('ROLE_ADMIN')")
        @PutMapping("/{id}/desactivar")
        public ResponseEntity<Void> desactivarUsuario(@PathVariable Long id) {
                usuarioService.cambiarEstadoUsuario(id, false);
                return ResponseEntity.noContent().build();
        }

}
