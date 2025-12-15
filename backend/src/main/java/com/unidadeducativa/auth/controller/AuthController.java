package com.unidadeducativa.auth.controller;

import com.unidadeducativa.auth.dto.LoginRequest;
import com.unidadeducativa.auth.dto.LoginResponse;
import com.unidadeducativa.auth.dto.RegistroInstitucionRequest;
import com.unidadeducativa.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Autenticación", description = "Endpoints para login y registro de usuarios")
public class AuthController {

        private final AuthService authService;

        @Operation(summary = "Iniciar sesión", description = "Autentica a un usuario con su correo y contraseña. Devuelve un token JWT.")
        @ApiResponses(value = {
                        @ApiResponse(responseCode = "200", description = "Inicio de sesión exitoso", content = @Content(mediaType = "application/json", schema = @Schema(implementation = LoginResponse.class))),
                        @ApiResponse(responseCode = "401", description = "Credenciales inválidas", content = @Content)
        })
        @PostMapping("/login")
        public ResponseEntity<LoginResponse> login(
                        @io.swagger.v3.oas.annotations.parameters.RequestBody(description = "Credenciales de inicio de sesión", required = true, content = @Content(schema = @Schema(implementation = LoginRequest.class), examples = @ExampleObject(value = "{ \"correo\": \"usuario@correo.com\", \"password\": \"123456\" }"))) @RequestBody LoginRequest request) {
                return ResponseEntity.ok(authService.login(request));
        }

        @Operation(summary = "Registrar Institución Educativa", description = "Registra un nuevo colegio, crea su director y configura automáticamente la malla curricular base.")
        @ApiResponses(value = {
                        @ApiResponse(responseCode = "200", description = "Institución registrada exitosamente", content = @Content(schema = @Schema(implementation = LoginResponse.class))),
                        @ApiResponse(responseCode = "400", description = "Datos inválidos o duplicados")
        })
        @PostMapping("/register-school")
        public ResponseEntity<LoginResponse> registerSchool(@Valid @RequestBody RegistroInstitucionRequest request) {
                return ResponseEntity.ok(authService.registrarInstitucion(request));
        }
}
