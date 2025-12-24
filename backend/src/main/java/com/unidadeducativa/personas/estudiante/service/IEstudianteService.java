package com.unidadeducativa.personas.estudiante.service;

import com.unidadeducativa.personas.estudiante.dto.EstudianteRequestDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteResponseDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteUpdateDTO;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;

public interface IEstudianteService {
  Page<EstudianteResponseDTO> listarEstudiantes(Boolean estado, Pageable pageable);

  EstudianteResponseDTO obtenerPorId(Long id);

  EstudianteResponseDTO obtenerPorCorreo(String name);

  EstudianteResponseDTO actualizarEstudiante(Long id, EstudianteUpdateDTO dto);

  void eliminarEstudiante(Long id);

  EstudianteResponseDTO registrarEstudianteCompleto(EstudianteRequestDTO dto);

  void cambiarEstadoEstudiante(Long id, boolean estado);

  List<com.unidadeducativa.academia.gestion.dto.GestionResponseDTO> listarGestionesEstudiante(Long idEstudiante);

  EstudianteResponseDTO actualizarPorCorreo(String correo, EstudianteUpdateDTO dto);
}