package com.unidadeducativa.academia.curso.service;

import com.unidadeducativa.academia.curso.dto.CursoRequestDTO;
import com.unidadeducativa.academia.curso.dto.CursoResponseDTO;

import java.util.List;

public interface ICursoService {
    CursoResponseDTO crearCurso(CursoRequestDTO dto);
    List<CursoResponseDTO> listarCursos();
    CursoResponseDTO obtenerCursoPorId(Long id);
    CursoResponseDTO actualizarCurso(Long id, CursoRequestDTO dto);
    void eliminarCurso(Long id);
}
