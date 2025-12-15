package com.unidadeducativa.personas.director.service;

import com.unidadeducativa.personas.director.dto.DirectorRequestDTO;
import com.unidadeducativa.personas.director.dto.DirectorResponseDTO;
import com.unidadeducativa.personas.director.dto.DirectorUpdateDTO;

import java.util.List;

public interface IDirectorService {

    List<DirectorResponseDTO> listarDirectores();

    DirectorResponseDTO obtenerPorId(Long id);

    DirectorResponseDTO obtenerPorCorreo(String correo);

    DirectorResponseDTO registrarDirector(DirectorRequestDTO dto);

    DirectorResponseDTO actualizarDirector(Long id, DirectorUpdateDTO dto);

    DirectorResponseDTO actualizarPorCorreo(String correo, DirectorUpdateDTO dto);

    void eliminarDirector(Long id);

    void cambiarEstadoDirector(Long id, boolean estado);
}
