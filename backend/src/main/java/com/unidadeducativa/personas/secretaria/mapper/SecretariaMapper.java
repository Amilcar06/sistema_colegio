package com.unidadeducativa.personas.secretaria.mapper;

import com.unidadeducativa.personas.secretaria.dto.SecretariaRequestDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaResponseDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaUpdateDTO;
import com.unidadeducativa.personas.secretaria.model.Secretaria;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface SecretariaMapper {

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
    SecretariaResponseDTO toDTO(Secretaria secretaria);

    // ================================================
    // UPDATE DTO -> ENTITY (solo campos editables)
    // ================================================

    @Mapping(target = "idSecretaria", ignore = true)
    @Mapping(target = "usuario", ignore = true)
    void updateFromDTO(SecretariaUpdateDTO dto, @MappingTarget Secretaria secretaria);

    // ================================================
    // REGISTRO COMPLETO DTO -> USUARIO Y SECRETARIA
    // ================================================

    // Usuario se crea manualmente desde el DTO (fuera del mapper)
    @Mapping(target = "idSecretaria", ignore = true)
    @Mapping(target = "usuario", ignore = true)
    Secretaria toEntity(SecretariaRequestDTO dto);
}
