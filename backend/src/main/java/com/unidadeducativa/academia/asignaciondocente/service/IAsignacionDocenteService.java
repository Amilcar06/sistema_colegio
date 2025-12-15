package com.unidadeducativa.academia.asignaciondocente.service;

import com.unidadeducativa.academia.asignaciondocente.dto.AsignacionDocenteRequestDTO;
import com.unidadeducativa.academia.asignaciondocente.dto.AsignacionDocenteResponseDTO;

import java.util.List;

public interface IAsignacionDocenteService {

    AsignacionDocenteResponseDTO crear(AsignacionDocenteRequestDTO dto);

    AsignacionDocenteResponseDTO actualizar(Long id, AsignacionDocenteRequestDTO dto);

    void eliminar(Long id);

    List<AsignacionDocenteResponseDTO> listarPorCurso(Long idCurso);

    List<AsignacionDocenteResponseDTO> listarPorProfesor(Long idProfesor);

    List<AsignacionDocenteResponseDTO> listarMateriasAsignadasPorCurso(Long idCurso);

    List<AsignacionDocenteResponseDTO> listarPorUsuario(String correo);
}
