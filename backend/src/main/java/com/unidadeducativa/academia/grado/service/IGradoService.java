package com.unidadeducativa.academia.grado.service;

import com.unidadeducativa.academia.grado.dto.*;
import com.unidadeducativa.shared.enums.TipoNivel;

import java.util.List;

public interface IGradoService {
    GradoResponseDTO registrar(GradoRequestDTO dto);
    GradoResponseDTO obtenerPorId(Long id);
    List<GradoResponseDTO> listar();
    GradoResponseDTO actualizar(Long id, GradoUpdateDTO dto);
    void eliminar(Long id);
    List<GradoResponseDTO> listarPorNivel(TipoNivel nivel);
}
