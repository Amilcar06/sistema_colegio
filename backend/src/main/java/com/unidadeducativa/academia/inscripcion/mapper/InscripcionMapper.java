package com.unidadeducativa.academia.inscripcion.mapper;

import com.unidadeducativa.academia.inscripcion.dto.InscripcionConMateriasResponseDTO;
import com.unidadeducativa.academia.inscripcionmateria.dto.InscripcionMateriaResponseDTO;
import com.unidadeducativa.academia.inscripcion.dto.InscripcionResponseDTO;
import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.inscripcionmateria.model.InscripcionMateria;
import com.unidadeducativa.personas.estudiante.mapper.EstudianteMapper;
import com.unidadeducativa.academia.curso.mapper.CursoMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring", uses = { EstudianteMapper.class, CursoMapper.class })
public interface InscripcionMapper {

    // Mapper para Inscripcion → InscripcionResponseDTO
    @Mapping(source = "idInscripcion", target = "idInscripcion")
    @Mapping(source = "estudiante.idEstudiante", target = "idEstudiante")
    @Mapping(source = "estudiante", target = "estudiante")
    @Mapping(source = "curso.idCurso", target = "idCurso")
    @Mapping(source = "curso", target = "curso")
    @Mapping(source = "gestion.idGestion", target = "idGestion")
    @Mapping(source = "gestion.anio", target = "anioGestion")
    @Mapping(source = "fechaInscripcion", target = "fechaInscripcion")
    @Mapping(expression = "java(inscripcion.getEstado().name())", target = "estado")
    InscripcionResponseDTO toDTO(Inscripcion inscripcion);

    // Mapper para Inscripcion → InscripcionConMateriasResponseDTO
    @Mapping(source = "inscripcion.idInscripcion", target = "idInscripcion")
    @Mapping(source = "inscripcion.estudiante.idEstudiante", target = "idEstudiante")
    @Mapping(expression = "java(inscripcion.getEstudiante().getUsuario().getNombreCompleto())", target = "nombreEstudiante")
    @Mapping(source = "inscripcion.curso.idCurso", target = "idCurso")
    @Mapping(expression = "java(inscripcion.getCurso().getGrado().getNombre() + \" \" + inscripcion.getCurso().getParalelo())", target = "nombreCurso")
    @Mapping(source = "inscripcion.gestion.idGestion", target = "idGestion")
    @Mapping(source = "inscripcion.gestion.anio", target = "anioGestion")
    @Mapping(source = "inscripcion.fechaInscripcion", target = "fechaInscripcion")
    @Mapping(expression = "java(inscripcion.getEstado().name())", target = "estado")
    @Mapping(source = "materias", target = "materiasAsignadas", qualifiedByName = "mapMaterias")
    InscripcionConMateriasResponseDTO toDTOConMaterias(Inscripcion inscripcion, List<InscripcionMateria> materias);

    // Conversor para lista de materias
    @Named("mapMaterias")
    default List<InscripcionMateriaResponseDTO> mapMaterias(List<InscripcionMateria> materias) {
        return materias.stream().map(m -> InscripcionMateriaResponseDTO.builder()
                .idInscripcionMateria(m.getIdInscripcionMateria())
                .idInscripcion(m.getInscripcion().getIdInscripcion())
                .idMateria(m.getMateria().getIdMateria())
                .nombreMateria(m.getMateria().getNombre())
                .build()).collect(Collectors.toList());
    }
}
