package com.unidadeducativa.notificaciones.controller;

import com.unidadeducativa.exceptions.NotFoundException;
import com.unidadeducativa.notificaciones.dto.NotificacionResponseDTO;
import com.unidadeducativa.notificaciones.model.Notificacion;
import com.unidadeducativa.notificaciones.repository.NotificacionRepository;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notificaciones")
@RequiredArgsConstructor
@Tag(name = "Notificaciones", description = "Sistema de notificaciones in-app")
public class NotificacionController {

    private final NotificacionRepository notificacionRepository;
    private final UsuarioRepository usuarioRepository;

    @Operation(summary = "Obtener mis notificaciones")
    @GetMapping("/mis-notificaciones")
    public ResponseEntity<List<NotificacionResponseDTO>> obtenerMisNotificaciones(Authentication authentication) {
        String email = authentication.getName();
        Usuario usuario = usuarioRepository.findByCorreo(email)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado"));

        List<Notificacion> notas = notificacionRepository
                .findByUsuarioIdUsuarioOrderByFechaCreacionDesc(usuario.getIdUsuario());

        List<NotificacionResponseDTO> dtos = notas.stream().map(n -> NotificacionResponseDTO.builder()
                .idNotificacion(n.getIdNotificacion())
                .titulo(n.getTitulo())
                .mensaje(n.getMensaje())
                .leido(n.isLeido())
                .fechaCreacion(n.getFechaCreacion())
                .build()).collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    @Operation(summary = "Marcar notificación como leída")
    @PutMapping("/{id}/leer")
    public ResponseEntity<Void> marcarComoLeida(@PathVariable Long id, Authentication authentication) {
        String email = authentication.getName();
        Notificacion notificacion = notificacionRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Notificación no encontrada"));

        // Validar que pertenezca al usuario
        if (!notificacion.getUsuario().getCorreo().equals(email)) {
            throw new IllegalArgumentException("No tienes permiso para acceder a esta notificación");
        }

        notificacion.setLeido(true);
        notificacionRepository.save(notificacion);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Contar notificaciones no leídas")
    @GetMapping("/count-unread")
    public ResponseEntity<Long> contarNoLeidas(Authentication authentication) {
        String email = authentication.getName();
        Usuario usuario = usuarioRepository.findByCorreo(email)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado"));

        long count = notificacionRepository.countByUsuarioIdUsuarioAndLeidoFalse(usuario.getIdUsuario());
        return ResponseEntity.ok(count);
    }
}
