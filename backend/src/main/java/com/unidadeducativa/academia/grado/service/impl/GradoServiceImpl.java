package com.unidadeducativa.academia.grado.service.impl;

import com.unidadeducativa.academia.grado.dto.*;
import com.unidadeducativa.academia.grado.mapper.GradoMapper;
import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.academia.grado.repository.GradoRepository;
import com.unidadeducativa.academia.grado.service.IGradoService;
import com.unidadeducativa.exceptions.NotFoundException;
import com.unidadeducativa.shared.enums.TipoNivel;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GradoServiceImpl implements IGradoService {

    private final GradoRepository gradoRepository;
    private final GradoMapper gradoMapper;

    @Override
    public GradoResponseDTO registrar(GradoRequestDTO dto) {
        if (gradoRepository.existsByNombre(dto.getNombre())) {
            throw new IllegalArgumentException("Ya existe un grado con el nombre: " + dto.getNombre());
        }
        Grado grado = gradoMapper.toEntity(dto);
        return gradoMapper.toDTO(gradoRepository.save(grado));
    }

    @Override
    public GradoResponseDTO obtenerPorId(Long id) {
        Grado grado = gradoRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Grado no encontrado con ID: " + id));
        return gradoMapper.toDTO(grado);
    }

    @Override
    public List<GradoResponseDTO> listar() {
        return gradoRepository.findAll()
                .stream()
                .map(gradoMapper::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    public GradoResponseDTO actualizar(Long id, GradoUpdateDTO dto) {
        Grado grado = gradoRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Grado no encontrado con ID: " + id));
        gradoMapper.updateFromDTO(dto, grado);
        return gradoMapper.toDTO(gradoRepository.save(grado));
    }

    @Override
    public void eliminar(Long id) {
        Grado grado = gradoRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Grado no encontrado con ID: " + id));
        gradoRepository.delete(grado);
    }

    @Override
    public List<GradoResponseDTO> listarPorNivel(TipoNivel nivel) {
        return gradoRepository.findByNivel(nivel)
                .stream()
                .map(gradoMapper::toDTO)
                .collect(Collectors.toList());
    }
}