package com.unidadeducativa.usuario.service.impl;

import com.unidadeducativa.usuario.dto.RolResponseDTO;
import com.unidadeducativa.usuario.mapper.RolMapper;
import com.unidadeducativa.usuario.repository.RolRepository;
import com.unidadeducativa.usuario.service.IRolService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RolServiceImpl implements IRolService {

    private final RolRepository rolRepository;
    private final RolMapper rolMapper;

    @Override
    public List<RolResponseDTO> listarTodos() {
        return rolRepository.findAll().stream()
                .map(rolMapper::toDTO)
                .collect(Collectors.toList());
    }
}
