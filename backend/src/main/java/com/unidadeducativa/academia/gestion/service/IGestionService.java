package com.unidadeducativa.academia.gestion.service;

import com.unidadeducativa.academia.gestion.dto.GestionRequestDTO;
import com.unidadeducativa.academia.gestion.dto.GestionResponseDTO;
import com.unidadeducativa.academia.gestion.dto.GestionUpdateDTO;

import java.util.List;

public interface IGestionService {
    List<GestionResponseDTO> listarGestiones();
    GestionResponseDTO obtenerGestionActual();
    GestionResponseDTO registrarGestion(GestionRequestDTO dto);
    GestionResponseDTO actualizarGestion(Long id, GestionUpdateDTO dto);
    void eliminarGestion(Long id);
}
