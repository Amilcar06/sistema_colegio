package com.unidadeducativa.academia.gestion.service.impl;

import com.unidadeducativa.academia.gestion.dto.GestionRequestDTO;
import com.unidadeducativa.academia.gestion.dto.GestionResponseDTO;
import com.unidadeducativa.academia.gestion.dto.GestionUpdateDTO;
import com.unidadeducativa.academia.gestion.mapper.GestionMapper;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.gestion.repository.GestionRepository;
import com.unidadeducativa.academia.gestion.service.IGestionService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GestionServiceImpl implements IGestionService {

    private final GestionRepository gestionRepository;
    private final GestionMapper gestionMapper;

    @Override
    public List<GestionResponseDTO> listarGestiones() {
        return gestionRepository.findAll()
                .stream()
                .map(gestionMapper::toDTO)
                .toList();
    }

    @Override
    public GestionResponseDTO obtenerGestionActual() {
        int anioActual = LocalDate.now().getYear();

        GestionAcademica gestion = gestionRepository.findByAnio(anioActual)
                .orElseThrow(() -> new EntityNotFoundException("No existe gestión académica para el año actual: " + anioActual));

        return gestionMapper.toDTO(gestion);
    }

    @Override
    public GestionResponseDTO registrarGestion(GestionRequestDTO dto) {
        int anioActual = LocalDate.now().getYear();

        // Verificar si ya existe una gestión para el año actual
        if (gestionRepository.existsByAnio(anioActual)) {
            throw new IllegalArgumentException("Ya existe una gestión para el año actual: " + anioActual);
        }

        GestionAcademica nueva = GestionAcademica.builder()
                .anio(anioActual)
                .estado(dto.getEstado() != null ? dto.getEstado() : true)
                .build();

        return gestionMapper.toDTO(gestionRepository.save(nueva));
    }

    @Override
    public GestionResponseDTO actualizarGestion(Long id, GestionUpdateDTO dto) {
        GestionAcademica existente = gestionRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Gestión académica no encontrada con ID: " + id));

        gestionMapper.updateFromDTO(dto, existente);
        return gestionMapper.toDTO(gestionRepository.save(existente));
    }

    @Override
    public void eliminarGestion(Long id) {
        GestionAcademica gestion = gestionRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Gestión académica no encontrada con ID: " + id));
        gestionRepository.delete(gestion);
    }
}
