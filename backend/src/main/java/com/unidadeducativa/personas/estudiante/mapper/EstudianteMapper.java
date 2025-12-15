package com.unidadeducativa.personas.estudiante.mapper;

import com.unidadeducativa.personas.estudiante.dto.EstudianteRequestDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteResponseDTO;
import com.unidadeducativa.personas.estudiante.dto.EstudianteUpdateDTO;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface EstudianteMapper {

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
    EstudianteResponseDTO toDTO(Estudiante estudiante);

    // ================================================
    // UPDATE DTO -> ENTITY (solo campos editables)
    // ================================================

    @Mapping(target = "idEstudiante", ignore = true)
    @Mapping(target = "usuario", ignore = true)
    void updateFromDTO(EstudianteUpdateDTO dto, @MappingTarget Estudiante estudiante);

    // ================================================
    // REGISTRO COMPLETO DTO -> USUARIO Y ESTUDIANTE
    // ================================================

    @Mapping(target = "idEstudiante", ignore = true)
    @Mapping(target = "usuario", ignore = true) // Se setea manualmente
    Estudiante toEntity(EstudianteRequestDTO dto);
}
