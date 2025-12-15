package com.unidadeducativa.academia.nota.mapper;

import com.unidadeducativa.academia.nota.dto.*;
import com.unidadeducativa.academia.nota.model.Nota;
import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import org.springframework.stereotype.Component;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class NotaMapper {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE;

    // Mapea un DTO de request a entidad
    public Nota toEntity(NotaRequestDTO dto, Estudiante estudiante, AsignacionDocente asignacion) {
        return Nota.builder()
                .estudiante(estudiante)
                .asignacion(asignacion)
                .valor(dto.getValor())
                .trimestre(dto.getTrimestre())
                .build(); // fechaRegistro se asigna en la entidad automáticamente
    }

    // Mapea entidad a responseDTO individual
    public NotaResponseDTO toResponseDTO(Nota nota) {
        return NotaResponseDTO.builder()
                .idNota(nota.getIdNota())
                .idEstudiante(nota.getEstudiante().getIdEstudiante())
                .nombreEstudiante(nota.getEstudiante().getUsuario().getNombreCompleto())
                .idAsignacion(nota.getAsignacion().getIdAsignacion())
                .nombreMateria(nota.getAsignacion().getMateria().getNombre())
                .nombreProfesor(nota.getAsignacion().getProfesor().getUsuario().getNombreCompleto())
                .valor(nota.getValor())
                .trimestre(nota.getTrimestre())
                .fechaRegistro(nota.getFechaRegistro().format(FORMATTER))
                .build();
    }

    // Para boletín: agrupar notas por trimestre
    public NotaTrimestreDTO toTrimestreDTO(Nota nota) {
        return NotaTrimestreDTO.builder()
                .trimestre(nota.getTrimestre())
                .materia(nota.getAsignacion().getMateria().getNombre())
                .valor(nota.getValor())
                .nombreProfesor(nota.getAsignacion().getProfesor().getUsuario().getNombreCompleto())
                .build();
    }

    // Boletín general (usado en GET /boletin/{idEstudiante})
    public NotaBoletinDTO toBoletinDTO(Estudiante estudiante, String curso, String gestion, List<Nota> notas) {
        List<NotaTrimestreDTO> detalle = notas.stream()
                .map(this::toTrimestreDTO)
                .collect(Collectors.toList());

        return NotaBoletinDTO.builder()
                .idEstudiante(estudiante.getIdEstudiante())
                .nombreEstudiante(estudiante.getUsuario().getNombreCompleto())
                .curso(curso)
                .gestion(gestion)
                .notas(detalle)
                .build();
    }

    // Agrupamiento por trimestre (útil para GET /estudiante/{id}/trimestre/{tri})
    public Map<String, List<NotaResponseDTO>> agruparPorTrimestre(List<Nota> notas) {
        return notas.stream()
                .map(this::toResponseDTO)
                .collect(Collectors.groupingBy(n -> n.getTrimestre().name()));
    }
}
