package com.unidadeducativa.academia.inscripcionmateria.service;

import com.unidadeducativa.academia.inscripcionmateria.dto.InscripcionMateriaResponseDTO;

import java.util.List;

public interface IInscripcionMateriaService {

    List<InscripcionMateriaResponseDTO> listarPorInscripcion(Long idInscripcion);

    void asignarMateriasPorGrado(Long idInscripcion);
}
