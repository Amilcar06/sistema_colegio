package com.unidadeducativa.academia.materia.service;

import com.unidadeducativa.academia.materia.dto.MateriaRequestDTO;
import com.unidadeducativa.academia.materia.dto.MateriaResponseDTO;

import java.util.List;

public interface IMateriaService {
    MateriaResponseDTO crearMateria(MateriaRequestDTO dto);
    MateriaResponseDTO actualizarMateria(Long id, MateriaRequestDTO dto);
    MateriaResponseDTO obtenerMateria(Long id);
    List<MateriaResponseDTO> listarMaterias();
    void eliminarMateria(Long id);
}
