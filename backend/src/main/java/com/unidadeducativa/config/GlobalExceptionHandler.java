package com.unidadeducativa.config;

import com.unidadeducativa.exceptions.NotFoundException;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // Argumentos ilegales (Validaciones de negocio manuales)
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArgument(IllegalArgumentException ex) {
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error", ex.getMessage());
        return ResponseEntity.badRequest().body(respuesta);
    }

    // Errores de validación de campos (DTOs con @Valid)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationErrors(MethodArgumentNotValidException ex) {
        Map<String, String> errores = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String campo = ((FieldError) error).getField();
            String mensaje = error.getDefaultMessage();
            errores.put(campo, mensaje);
        });
        return ResponseEntity.badRequest().body(errores);
    }

    // JSON malformado o tipos de datos incorrectos en el body
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, String>> handleHttpMessageNotReadable(HttpMessageNotReadableException ex) {
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error",
                "Solicitud malformada: El JSON enviado no es válido o contiene tipos de datos incorrectos.");
        // Opcional: incluir ex.getMessage() si no expone info sensible
        return ResponseEntity.badRequest().body(respuesta);
    }

    // Recurso no encontrado (Custom Exception)
    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFoundException(NotFoundException ex) {
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(respuesta);
    }

    // Entidad no encontrada (JPA)
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleEntityNotFound(EntityNotFoundException ex) {
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error", "El recurso solicitado no existe.");
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(respuesta);
    }

    // URL no encontrada (Spring Boot 3+)
    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<Map<String, String>> handleNoResourceFound(NoResourceFoundException ex) {
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error", "La ruta solicitada no existe: " + ex.getResourcePath());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(respuesta);
    }

    // Acceso denegado (Falta de permisos/roles)
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String, String>> handleAccessDenied(AccessDeniedException ex) {
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error", "Acceso denegado: No tiene permisos para realizar esta acción.");
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(respuesta);
    }

    // Credenciales inválidas (Login fallido)
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<Map<String, String>> handleBadCredentials(BadCredentialsException ex) {
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error", "Credenciales incorrectas: Usuario o contraseña no válidos.");
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(respuesta);
    }

    // Violaciones de integridad, como duplicados de CI, correo, etc.
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, String>> handleDataIntegrityViolation(DataIntegrityViolationException ex) {
        Map<String, String> respuesta = new HashMap<>();
        String mensaje = "Violación de integridad de datos.";
        if (ex.getCause() != null && ex.getCause().getMessage() != null) {
            String causa = ex.getCause().getMessage().toLowerCase();
            if (causa.contains("duplicate") || causa.contains("unique")) {
                mensaje = "Ya existe un registro con estos datos únicos (ej. CI, Correo, Código).";
            } else if (causa.contains("foreign")) {
                mensaje = "No se puede eliminar o modificar porque está referenciado por otros registros.";
            }
        }
        respuesta.put("error", mensaje);
        return ResponseEntity.status(HttpStatus.CONFLICT).body(respuesta);
    }

    // Cualquier otra excepción no controlada
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception ex) {
        // Loguear el error real en consola/archivo logs
        ex.printStackTrace();

        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("error", "Ha ocurrido un error interno en el servidor.");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(respuesta);
    }
}
