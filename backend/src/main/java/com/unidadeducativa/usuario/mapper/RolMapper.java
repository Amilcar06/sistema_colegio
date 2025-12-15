package com.unidadeducativa.usuario.mapper;

import com.unidadeducativa.shared.enums.RolNombre;
import com.unidadeducativa.usuario.dto.RolResponseDTO;
import com.unidadeducativa.usuario.model.Rol;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface RolMapper {
    @Mapping(source = "idRol", target = "idRol")
    @Mapping(source = "nombre", target = "nombre")
    RolResponseDTO toDTO(Rol rol);

    default String map(RolNombre rolNombre) {
        return rolNombre != null ? rolNombre.name() : null;
    }
}