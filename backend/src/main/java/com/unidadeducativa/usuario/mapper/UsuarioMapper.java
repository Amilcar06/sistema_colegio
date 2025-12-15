package com.unidadeducativa.usuario.mapper;

import com.unidadeducativa.usuario.dto.*;
import com.unidadeducativa.usuario.model.Usuario;
import org.mapstruct.*;

@Mapper(componentModel = "spring", uses = RolMapper.class, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface UsuarioMapper {

    // Entidad a DTO
    @Mapping(source = "rol", target = "rol")
    UsuarioResponseDTO toDTO(Usuario usuario);

    // DTO a entidad para crear nuevo usuario
    @Mapping(target = "idUsuario", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "rol", ignore = true) // El rol se asigna manualmente desde el service
    @Mapping(source = "ci", target = "ci")
    Usuario toEntity(UsuarioRequestDTO dto);

    // Actualización parcial de Usuario (para patch/update)
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateFromDTO(UsuarioUpdateDTO dto, @MappingTarget Usuario usuario);
}
