package com.unidadeducativa.academia.gradomateria.mapper;

import com.unidadeducativa.academia.gradomateria.dto.GradoMateriaResponseDTO;
import com.unidadeducativa.academia.gradomateria.model.GradoMateria;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface GradoMateriaMapper {

    @Mapping(source = "grado.idGrado", target = "idGrado")
    @Mapping(source = "grado.nombre", target = "nombreGrado")
    @Mapping(source = "materia.idMateria", target = "idMateria")
    @Mapping(source = "materia.nombre", target = "nombreMateria")
    @Mapping(source = "gestion.idGestion", target = "idGestion")
    @Mapping(source = "gestion.anio", target = "anioGestion")
    GradoMateriaResponseDTO toDTO(GradoMateria entity);
}
