package com.unidadeducativa.academia.curso.controller;

import com.unidadeducativa.academia.curso.dto.CursoRequestDTO;
import com.unidadeducativa.academia.curso.dto.CursoResponseDTO;
import com.unidadeducativa.academia.curso.service.ICursoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cursos")
@RequiredArgsConstructor
@Tag(name = "Cursos", description = "Operaciones relacionadas con la gestión de cursos")
public class CursoController {

    private final ICursoService cursoService;

    @Operation(summary = "Crear un nuevo curso", description = "Registra un nuevo curso indicando el id del grado, paralelo y turno.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Curso creado exitosamente",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = CursoResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content)
    })
    @PostMapping
    public ResponseEntity<CursoResponseDTO> crear(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Datos del curso a registrar",
                    required = true,
                    content = @Content(
                            schema = @Schema(implementation = CursoRequestDTO.class),
                            examples = @ExampleObject(
                                    value = "{\n" +
                                            "  \"idGrado\": 1,\n" +
                                            "  \"paralelo\": \"A\",\n" +
                                            "  \"turno\": \"Mañana\"\n" +
                                            "}"
                            )
                    )
            )
            @Valid @RequestBody CursoRequestDTO dto) {
        return ResponseEntity.ok(cursoService.crearCurso(dto));
    }

    @Operation(summary = "Listar todos los cursos", description = "Devuelve una lista de todos los cursos registrados.")
    @ApiResponse(responseCode = "200", description = "Lista de cursos obtenida exitosamente",
            content = @Content(mediaType = "application/json",
                    array = @ArraySchema(schema = @Schema(implementation = CursoResponseDTO.class))))
    @GetMapping
    public ResponseEntity<List<CursoResponseDTO>> listar() {
        return ResponseEntity.ok(cursoService.listarCursos());
    }

    @Operation(summary = "Obtener curso por ID", description = "Devuelve los datos de un curso específico mediante su ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Curso encontrado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = CursoResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "Curso no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<CursoResponseDTO> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(cursoService.obtenerCursoPorId(id));
    }

    @Operation(summary = "Actualizar curso por ID", description = "Modifica los datos de un curso existente.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Curso actualizado exitosamente",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = CursoResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
            @ApiResponse(responseCode = "404", description = "Curso no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<CursoResponseDTO> actualizar(
            @PathVariable Long id,
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Datos actualizados del curso",
                    required = true,
                    content = @Content(
                            schema = @Schema(implementation = CursoRequestDTO.class),
                            examples = @ExampleObject(
                                    value = "{\n" +
                                            "  \"idGrado\": 2,\n" +
                                            "  \"paralelo\": \"B\",\n" +
                                            "  \"turno\": \"Tarde\"\n" +
                                            "}"
                            )
                    )
            )
            @Valid @RequestBody CursoRequestDTO dto) {
        return ResponseEntity.ok(cursoService.actualizarCurso(id, dto));
    }

    @Operation(summary = "Eliminar curso por ID", description = "Elimina un curso del sistema a partir de su ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Curso eliminado exitosamente"),
            @ApiResponse(responseCode = "404", description = "Curso no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        cursoService.eliminarCurso(id);
        return ResponseEntity.noContent().build();
    }
}
