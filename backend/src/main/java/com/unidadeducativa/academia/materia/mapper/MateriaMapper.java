package com.unidadeducativa.academia.materia.mapper;

import com.unidadeducativa.academia.materia.dto.MateriaRequestDTO;
import com.unidadeducativa.academia.materia.dto.MateriaResponseDTO;
import com.unidadeducativa.academia.materia.model.Materia;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface MateriaMapper {

    MateriaResponseDTO toDTO(Materia materia);

    @Mapping(target = "unidadEducativa", ignore = true)
    @Mapping(target = "idMateria", ignore = true)
    Materia toEntity(MateriaRequestDTO dto);
}
