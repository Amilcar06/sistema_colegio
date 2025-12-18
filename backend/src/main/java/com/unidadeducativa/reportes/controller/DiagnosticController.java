package com.unidadeducativa.reportes.controller;

import com.unidadeducativa.usuario.repository.UsuarioRepository;
import com.unidadeducativa.shared.enums.RolNombre;
import com.unidadeducativa.usuario.model.Usuario;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/diagnostico")
@RequiredArgsConstructor
public class DiagnosticController {

    private final UsuarioRepository usuarioRepository;

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> diagnostico(Authentication auth) {
        Map<String, Object> result = new HashMap<>();

        String correo = auth.getName();
        result.put("usuario_autenticado", correo);

        Usuario usuario = usuarioRepository.findByCorreo(correo).orElse(null);
        if (usuario == null) {
            result.put("error", "Usuario no encontrado en DB");
            return ResponseEntity.ok(result);
        }

        Long ueId = (usuario.getUnidadEducativa() != null) ? usuario.getUnidadEducativa().getIdUnidadEducativa() : null;
        result.put("unidad_educativa_id", ueId);

        if (ueId == null) {
            result.put("warning", "El usuario no tiene Unidad Educativa asignada");
        }

        // Count all students
        long totalEstudiantes = usuarioRepository.countByRol_Nombre(RolNombre.ESTUDIANTE);
        result.put("total_estudiantes_en_db", totalEstudiantes);

        if (ueId != null) {
            long estudiantesConUE = usuarioRepository.countByRol_NombreAndUnidadEducativa_IdUnidadEducativa(
                    RolNombre.ESTUDIANTE, ueId);
            result.put("estudiantes_asociados_a_tu_ue", estudiantesConUE);
        }

        // Count orphaned students (manual check logic if needed, but total vs assigned
        // is enough hint)

        return ResponseEntity.ok(result);
    }
}
