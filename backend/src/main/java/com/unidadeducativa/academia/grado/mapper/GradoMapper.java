package com.unidadeducativa.academia.grado.mapper;

import com.unidadeducativa.academia.grado.dto.*;
import com.unidadeducativa.academia.grado.model.Grado;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface GradoMapper {

    GradoResponseDTO toDTO(Grado grado);
    @Mapping(target = "idGrado", ignore = true)
    Grado toEntity(GradoRequestDTO dto);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "idGrado", ignore = true)
    void updateFromDTO(GradoUpdateDTO dto, @MappingTarget Grado grado);
}
