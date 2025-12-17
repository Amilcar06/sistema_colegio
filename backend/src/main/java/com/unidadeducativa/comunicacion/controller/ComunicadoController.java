package com.unidadeducativa.comunicacion.controller;

import com.unidadeducativa.comunicacion.dto.ComunicadoRequestDTO;
import com.unidadeducativa.comunicacion.dto.ComunicadoResponseDTO;
import com.unidadeducativa.comunicacion.service.ComunicadoService;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/comunicados")
@RequiredArgsConstructor
@Tag(name = "Comunicación - Noticias", description = "Gestión de comunicados escolares")
public class ComunicadoController {

    private final ComunicadoService comunicadoService;
    private final UsuarioRepository usuarioRepository;

    @Operation(summary = "Crear un nuevo comunicado")
    @PreAuthorize("hasAnyRole('ROLE_DIRECTOR', 'ROLE_PROFESOR')")
    @PostMapping
    public ResponseEntity<ComunicadoResponseDTO> crearComunicado(@Valid @RequestBody ComunicadoRequestDTO request,
            Authentication authentication) {
        Usuario autor = usuarioRepository.findByCorreo(authentication.getName())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return ResponseEntity.ok(comunicadoService.crearComunicado(request, autor));
    }

    @Operation(summary = "Listar comunicados visibles para el usuario actual")
    @GetMapping
    public ResponseEntity<List<ComunicadoResponseDTO>> listarComunicados(Authentication authentication) {
        Usuario usuario = usuarioRepository.findByCorreo(authentication.getName())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return ResponseEntity.ok(comunicadoService.listarComunicados(usuario));
    }
}
