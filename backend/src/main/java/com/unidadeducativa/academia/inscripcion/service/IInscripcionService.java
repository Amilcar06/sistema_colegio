package com.unidadeducativa.academia.inscripcion.service;

import com.unidadeducativa.academia.inscripcion.dto.*;

import java.util.List;

public interface IInscripcionService {
    InscripcionResponseDTO registrar(InscripcionRequestDTO dto);
    List<InscripcionResponseDTO> listar();

    List<InscripcionResponseDTO> listarPorEstudiante(Long idEstudiante);
    List<InscripcionResponseDTO> listarPorCurso(Long idCurso);
    List<InscripcionResponseDTO> listarPorGestion(Long idGestion);
    List<InscripcionResponseDTO> listarEstudiantesPorCurso(Long idCurso);
    List<InscripcionResponseDTO> listarPorCursoYGestion(Long idCurso, Long idGestion);
    void cambiarEstadoInscripcion(InscripcionEstadoRequestDTO dto);
}
