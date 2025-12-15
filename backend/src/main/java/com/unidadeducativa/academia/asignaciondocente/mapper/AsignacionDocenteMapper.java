package com.unidadeducativa.academia.asignaciondocente.mapper;

import com.unidadeducativa.academia.asignaciondocente.dto.AsignacionDocenteResponseDTO;
import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface AsignacionDocenteMapper {

    @Mapping(target = "idProfesor", source = "profesor.idProfesor")
    @Mapping(target = "nombreProfesor", source = "profesor.usuario.nombres")
    @Mapping(target = "idMateria", source = "materia.idMateria")
    @Mapping(target = "nombreMateria", source = "materia.nombre")
    @Mapping(target = "idCurso", source = "curso.idCurso")
    @Mapping(target = "nombreCurso", expression = "java(asignacion.getCurso().getGrado().getNombre() + \" \" + asignacion.getCurso().getParalelo() + \" - \" + asignacion.getCurso().getTurno())")
    @Mapping(target = "idGestion", source = "gestion.idGestion")
    @Mapping(target = "anioGestion", source = "gestion.anio")
    AsignacionDocenteResponseDTO toDTO(AsignacionDocente asignacion);
}
