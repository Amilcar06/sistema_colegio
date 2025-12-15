package com.unidadeducativa.academia.curso.mapper;

import com.unidadeducativa.academia.curso.dto.CursoRequestDTO;
import com.unidadeducativa.academia.curso.dto.CursoResponseDTO;
import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.grado.model.Grado;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface CursoMapper {

    @Mapping(source = "grado.idGrado", target = "idGrado")
    @Mapping(source = "grado.nombre", target = "nombreGrado")
    @Mapping(source = "grado.nivel", target = "nivel")
    CursoResponseDTO toDTO(Curso curso);

    @Mapping(target = "idCurso", ignore = true)
    @Mapping(target = "grado", source = "idGrado", qualifiedByName = "idToGrado")
    Curso toEntity(CursoRequestDTO dto);

    // Necesitas definir cómo convertir idGrado -> Grado
    @Named("idToGrado")
    default Grado idToGrado(Long idGrado) {
        if (idGrado == null) {
            return null;
        }
        Grado grado = new Grado();
        grado.setIdGrado(idGrado);
        return grado;
    }
}
