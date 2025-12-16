package com.unidadeducativa.personas.estudiante.service;

import com.unidadeducativa.personas.estudiante.dto.EstudianteRequestDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteResponseDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteUpdateDTO;

import java.util.List;

public interface IEstudianteService {
  List<EstudianteResponseDTO> listarEstudiantes(Boolean estado);

  EstudianteResponseDTO obtenerPorId(Long id);

  EstudianteResponseDTO obtenerPorCorreo(String name);

  EstudianteResponseDTO actualizarEstudiante(Long id, EstudianteUpdateDTO dto);

  void eliminarEstudiante(Long id);

  EstudianteResponseDTO registrarEstudianteCompleto(EstudianteRequestDTO dto);

  void cambiarEstadoEstudiante(Long id, boolean estado);

  List<com.unidadeducativa.academia.gestion.dto.GestionResponseDTO> listarGestionesEstudiante(Long idEstudiante);

  EstudianteResponseDTO actualizarPorCorreo(String correo, EstudianteUpdateDTO dto);
}