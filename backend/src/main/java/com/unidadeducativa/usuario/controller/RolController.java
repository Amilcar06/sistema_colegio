package com.unidadeducativa.usuario.controller;

import com.unidadeducativa.usuario.dto.RolResponseDTO;
import com.unidadeducativa.usuario.service.IRolService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/roles")
@RequiredArgsConstructor
@Tag(name = "Roles", description = "Operaciones relacionadas con la gestión de roles")
public class RolController {

    private final IRolService rolService;

    @Operation(summary = "Listar todos los roles", description = "Devuelve una lista con todos los roles registrados.")
    @GetMapping
    public ResponseEntity<List<RolResponseDTO>> listarRoles() {
        return ResponseEntity.ok(rolService.listarTodos());
    }
}
