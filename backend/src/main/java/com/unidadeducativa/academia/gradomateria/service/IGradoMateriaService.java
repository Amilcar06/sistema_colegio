package com.unidadeducativa.academia.gradomateria.service;

import com.unidadeducativa.academia.gradomateria.dto.GradoMateriaRequestDTO;
import com.unidadeducativa.academia.gradomateria.dto.GradoMateriaResponseDTO;

import java.util.List;

public interface IGradoMateriaService {
    GradoMateriaResponseDTO crear(GradoMateriaRequestDTO dto);
    List<GradoMateriaResponseDTO> listar();
    GradoMateriaResponseDTO obtenerPorId(Long id);
    GradoMateriaResponseDTO actualizar(Long id, GradoMateriaRequestDTO dto);
    void eliminar(Long id);
}
