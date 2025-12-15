package com.unidadeducativa.academia.gestion.mapper;

import com.unidadeducativa.academia.gestion.dto.GestionRequestDTO;
import com.unidadeducativa.academia.gestion.dto.GestionResponseDTO;
import com.unidadeducativa.academia.gestion.dto.GestionUpdateDTO;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface GestionMapper {

    // ================================================
    // ENTITY -> RESPONSE DTO
    // ================================================
    GestionResponseDTO toDTO(GestionAcademica gestion);

    // ================================================
    // REGISTRO DTO -> ENTITY
    // ================================================
    @Mapping(target = "idGestion", ignore = true)
    @Mapping(target = "estado", constant = "true") // Siempre activa al crear
    @Mapping(target = "anio", ignore = true)
    @Mapping(target = "unidadEducativa", ignore = true)
    GestionAcademica toEntity(GestionRequestDTO dto);

    @Mapping(target = "unidadEducativa", ignore = true)
    GestionAcademica update(@MappingTarget GestionAcademica entity, GestionUpdateDTO dto);

    // ================================================
    // UPDATE DTO -> ENTITY (actualiza campos editables)
    // ================================================
    @Mapping(target = "idGestion", ignore = true)
    void updateFromDTO(GestionUpdateDTO dto, @MappingTarget GestionAcademica gestion);
}
