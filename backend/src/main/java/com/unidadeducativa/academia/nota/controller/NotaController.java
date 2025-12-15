package com.unidadeducativa.academia.nota.controller;

import com.unidadeducativa.academia.nota.dto.NotaBoletinDTO;
import com.unidadeducativa.academia.nota.dto.NotaBulkRequestDTO;
import com.unidadeducativa.academia.nota.dto.NotaRequestDTO;
import com.unidadeducativa.academia.nota.dto.NotaResponseDTO;
import com.unidadeducativa.academia.nota.dto.LibretaDigitalDTO;
import com.unidadeducativa.academia.nota.service.INotaService;
import com.unidadeducativa.shared.enums.Trimestre;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notas")
@RequiredArgsConstructor
@Tag(name = "Notas", description = "Gestión de notas académicas")
public class NotaController {

    private final INotaService notaService;

    // -----------------------------------
    // 1. Registrar nota individual
    // -----------------------------------
    @Operation(summary = "Registrar nota individual")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Nota registrada", content = @Content(schema = @Schema(implementation = NotaResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Error en los datos")
    })
    @PreAuthorize("hasAnyRole('ROLE_ADMIN','ROLE_PROFESOR')")
    @PostMapping
    public ResponseEntity<NotaResponseDTO> registrar(@Valid @RequestBody NotaRequestDTO dto) {
        return ResponseEntity.ok(notaService.registrarNota(dto));
    }

    // -----------------------------------
    // 2. Cargar notas masivas
    // -----------------------------------
    @Operation(summary = "Cargar notas masivas")
    @ApiResponse(responseCode = "200", description = "Notas procesadas")
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_PROFESOR')")
    @PostMapping("/bulk")
    public ResponseEntity<Void> registrarNotasMasivas(@Valid @RequestBody NotaBulkRequestDTO dto) {
        notaService.registrarNotasMasivas(dto);
        return ResponseEntity.ok().build();
    }

    // -----------------------------------
    // 3. Obtener notas por estudiante
    // -----------------------------------
    @Operation(summary = "Obtener notas por estudiante")
    @ApiResponse(responseCode = "200", description = "Notas obtenidas", content = @Content(array = @ArraySchema(schema = @Schema(implementation = NotaResponseDTO.class))))
    @PreAuthorize("hasAnyRole('ROLE_ADMIN','ROLE_PROFESOR', 'ROLE_SECRETARIA', 'ROLE_ESTUDIANTE', 'ROLE_ALUMNO')")
    @GetMapping("/estudiante/{id}")
    public ResponseEntity<List<NotaResponseDTO>> obtenerNotasPorEstudiante(@PathVariable Long id) {
        return ResponseEntity.ok(notaService.obtenerNotasPorEstudiante(id));
    }

    // -----------------------------------
    // 4. Obtener notas por estudiante y trimestre
    // -----------------------------------
    @Operation(summary = "Obtener notas por estudiante y trimestre")
    @ApiResponse(responseCode = "200", description = "Notas obtenidas", content = @Content(array = @ArraySchema(schema = @Schema(implementation = NotaResponseDTO.class))))
    @PreAuthorize("hasAnyRole('ROLE_ADMIN','ROLE_PROFESOR', 'ROLE_SECRETARIA', 'ROLE_ESTUDIANTE', 'ROLE_ALUMNO')")
    @GetMapping("/estudiante/{id}/trimestre/{trimestre}")
    public ResponseEntity<List<NotaResponseDTO>> obtenerNotasPorEstudianteYTrimestre(
            @PathVariable Long id,
            @PathVariable Trimestre trimestre) {
        return ResponseEntity.ok(notaService.obtenerNotasPorEstudianteYTrimestre(id, trimestre));
    }

    // -----------------------------------
    // 5. Actualizar nota
    // -----------------------------------
    @Operation(summary = "Actualizar nota existente")
    @ApiResponse(responseCode = "200", description = "Nota actualizada", content = @Content(schema = @Schema(implementation = NotaResponseDTO.class)))
    @PreAuthorize("hasAnyRole('ROLE_ADMIN','ROLE_PROFESOR')")
    @PutMapping("/{id}")
    public ResponseEntity<NotaResponseDTO> actualizarNota(
            @PathVariable Long id,
            @Valid @RequestBody NotaRequestDTO dto) {
        return ResponseEntity.ok(notaService.actualizarNota(id, dto));
    }

    // -----------------------------------
    // 6. Eliminar nota
    // -----------------------------------
    @Operation(summary = "Eliminar nota")
    @ApiResponse(responseCode = "204", description = "Nota eliminada correctamente")
    @PreAuthorize("hasAnyRole('ROLE_ADMIN','ROLE_PROFESOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarNota(@PathVariable Long id) {
        notaService.eliminarNota(id);
        return ResponseEntity.noContent().build();
    }

    // -----------------------------------
    // 7. Obtener boletín de estudiante
    // -----------------------------------
    @Operation(summary = "Obtener boletín del estudiante")
    @ApiResponse(responseCode = "200", description = "Boletín generado correctamente", content = @Content(schema = @Schema(implementation = NotaBoletinDTO.class)))
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_ESTUDIANTE', 'ROLE_SECRETARIA')")
    @GetMapping("/boletin/{idEstudiante}")
    public ResponseEntity<NotaBoletinDTO> obtenerBoletinPorEstudiante(@PathVariable Long idEstudiante) {
        return ResponseEntity.ok(notaService.obtenerBoletin(idEstudiante));
    }

    // -----------------------------------
    // 8. Obtener libreta digital (profesor)
    // -----------------------------------
    @Operation(summary = "Obtener libreta digital por asignación")
    @PreAuthorize("hasAnyRole('ROLE_PROFESOR','ROLE_ADMIN','ROLE_DIRECTOR')")
    @GetMapping("/asignacion/{id}/libreta")
    public ResponseEntity<LibretaDigitalDTO> obtenerLibretaPorAsignacion(@PathVariable Long id) {
        return ResponseEntity.ok(notaService.obtenerLibreta(id));
    }
}
