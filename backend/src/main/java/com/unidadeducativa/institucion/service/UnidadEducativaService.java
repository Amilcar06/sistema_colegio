package com.unidadeducativa.institucion.service;

import com.unidadeducativa.institucion.dto.UnidadEducativaDTO;
import com.unidadeducativa.institucion.model.UnidadEducativa;
import com.unidadeducativa.institucion.repository.UnidadEducativaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UnidadEducativaService {

    private final UnidadEducativaRepository repository;

    // Asumimos que solo hay una institución principal, por ejemplo con ID 1
    // O simplemente tomamos la primera que encontremos
    private static final Long ID_PRINCIPAL = 1L;

    public UnidadEducativaDTO obtenerPrincipal() {
        UnidadEducativa ue = repository.findById(ID_PRINCIPAL)
                .or(() -> repository.findAll().stream().findFirst())
                .orElseThrow(() -> new RuntimeException("No hay ninguna Unidad Educativa configurada."));

        return mapToDTO(ue);
    }

    @Transactional
    public UnidadEducativaDTO actualizarPrincipal(UnidadEducativaDTO dto) {
        UnidadEducativa ue = repository.findById(ID_PRINCIPAL)
                .or(() -> repository.findAll().stream().findFirst())
                .orElseThrow(
                        () -> new RuntimeException("No hay ninguna Unidad Educativa configurada para actualizar."));

        ue.setNombre(dto.getNombre());
        ue.setSie(dto.getSie());
        ue.setDireccion(dto.getDireccion());
        ue.setLogoUrl(dto.getLogoUrl());

        UnidadEducativa updated = repository.save(ue);
        return mapToDTO(updated);
    }

    private UnidadEducativaDTO mapToDTO(UnidadEducativa entity) {
        return UnidadEducativaDTO.builder()
                .idUnidadEducativa(entity.getIdUnidadEducativa())
                .nombre(entity.getNombre())
                .sie(entity.getSie())
                .direccion(entity.getDireccion())
                .logoUrl(entity.getLogoUrl())
                .build();
    }
}
