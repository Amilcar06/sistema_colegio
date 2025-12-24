package com.unidadeducativa.academia.inscripcion.service;

import com.unidadeducativa.academia.inscripcion.dto.*;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;

public interface IInscripcionService {
    InscripcionResponseDTO registrar(InscripcionRequestDTO dto);

    List<InscripcionResponseDTO> listar();

    List<InscripcionResponseDTO> listarPorEstudiante(Long idEstudiante);

    Page<InscripcionResponseDTO> listarPorCurso(Long idCurso, Pageable pageable);

    Page<InscripcionResponseDTO> listarPorGestion(Long idGestion, Pageable pageable);

    List<InscripcionResponseDTO> listarEstudiantesPorCurso(Long idCurso);

    List<InscripcionResponseDTO> listarPorCursoYGestion(Long idCurso, Long idGestion);

    void cambiarEstadoInscripcion(InscripcionEstadoRequestDTO dto);
}
