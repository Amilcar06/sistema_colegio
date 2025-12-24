package com.unidadeducativa.personas.profesor.service;

import com.unidadeducativa.personas.profesor.dto.ProfesorRequestDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorResponseDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorUpdateDTO;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;

public interface IProfesorService {
    Page<ProfesorResponseDTO> listarProfesores(Boolean estado, Pageable pageable);

    ProfesorResponseDTO obtenerPorId(Long id);

    ProfesorResponseDTO obtenerPorCorreo(String correo);

    ProfesorResponseDTO actualizarProfesor(Long id, ProfesorUpdateDTO dto);

    void eliminarProfesor(Long id);

    ProfesorResponseDTO registrarProfesorCompleto(ProfesorRequestDTO dto);

    void cambiarEstadoProfesor(Long id, boolean estado);

    ProfesorResponseDTO actualizarPorCorreo(String correo, ProfesorUpdateDTO dto);

    com.unidadeducativa.personas.profesor.dto.DashboardProfesorStatsDTO getDashboardStats(String correo);
}
