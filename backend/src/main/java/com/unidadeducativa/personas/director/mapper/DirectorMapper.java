package com.unidadeducativa.personas.director.mapper;

import com.unidadeducativa.personas.director.dto.DirectorRequestDTO;
import com.unidadeducativa.personas.director.dto.DirectorResponseDTO;
import com.unidadeducativa.personas.director.dto.DirectorUpdateDTO;
import com.unidadeducativa.personas.director.model.Director;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface DirectorMapper {

    // ================================================
    // ENTITY -> RESPONSE DTO (con datos de usuario)
    // ================================================

    @Mapping(source = "usuario.idUsuario", target = "idUsuario")
    @Mapping(source = "usuario.nombres", target = "nombres")
    @Mapping(source = "usuario.apellidoPaterno", target = "apellidoPaterno")
    @Mapping(source = "usuario.apellidoMaterno", target = "apellidoMaterno")
    @Mapping(source = "usuario.ci", target = "ci")
    @Mapping(source = "usuario.correo", target = "correo")
    @Mapping(source = "usuario.fotoPerfil", target = "fotoPerfil")
    @Mapping(source = "usuario.fechaNacimiento", target = "fechaNacimiento")
    @Mapping(source = "usuario.estado", target = "estado")
    @Mapping(source = "usuario.rol", target = "rol")
    DirectorResponseDTO toDTO(Director director);

    // ================================================
    // UPDATE DTO -> ENTITY (solo campos editables)
    // ================================================

    @Mapping(target = "idDirector", ignore = true)
    @Mapping(target = "usuario", ignore = true)
    void updateFromDTO(DirectorUpdateDTO dto, @MappingTarget Director director);

    // ================================================
    // REGISTRO COMPLETO DTO -> USUARIO Y DIRECTOR
    // ================================================

    // Usuario se crea manualmente desde el DTO (fuera del mapper)
    @Mapping(target = "idDirector", ignore = true)
    @Mapping(target = "usuario", ignore = true)
    Director toEntity(DirectorRequestDTO dto);
}
