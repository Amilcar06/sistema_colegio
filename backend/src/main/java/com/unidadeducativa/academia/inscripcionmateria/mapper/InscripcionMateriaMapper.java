package com.unidadeducativa.academia.inscripcionmateria.mapper;

import com.unidadeducativa.academia.inscripcionmateria.dto.InscripcionMateriaResponseDTO;
import com.unidadeducativa.academia.inscripcionmateria.model.InscripcionMateria;
import org.springframework.stereotype.Component;

@Component
public class InscripcionMateriaMapper {

    public InscripcionMateriaResponseDTO toDTO(InscripcionMateria entity) {
        return InscripcionMateriaResponseDTO.builder()
                .idInscripcionMateria(entity.getIdInscripcionMateria())
                .idInscripcion(entity.getInscripcion().getIdInscripcion())
                .idMateria(entity.getMateria().getIdMateria())
                .nombreMateria(entity.getMateria().getNombre())
                .build();
    }
}
