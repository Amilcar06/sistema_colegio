package com.unidadeducativa.personas.profesor.mapper;

import com.unidadeducativa.personas.profesor.dto.ProfesorRequestDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorResponseDTO;
import com.unidadeducativa.personas.profesor.dto.ProfesorUpdateDTO;
import com.unidadeducativa.personas.profesor.model.Profesor;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface ProfesorMapper {

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
    ProfesorResponseDTO toDTO(Profesor profesor);

    // ================================================
    // UPDATE DTO -> ENTITY (solo campos editables)
    // ================================================
    @Mapping(target = "idProfesor", ignore = true)
    @Mapping(target = "usuario", ignore = true)
    void updateFromDTO(ProfesorUpdateDTO dto, @MappingTarget Profesor profesor);

    // ================================================
    // REGISTRO COMPLETO DTO -> USUARIO Y PROFESOR
    // ================================================

    // Usuario se crea manualmente desde el DTO (fuera del mapper)
    @Mapping(target = "idProfesor", ignore = true)
    @Mapping(target = "usuario", ignore = true)
    Profesor toEntity(ProfesorRequestDTO dto);
}
