package com.unidadeducativa.finanzas.mapper;

import com.unidadeducativa.finanzas.dto.TipoPagoRequestDTO;
import com.unidadeducativa.finanzas.model.TipoPago;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface TipoPagoMapper {
    @Mapping(target = "idTipoPago", ignore = true)
    @Mapping(target = "unidadEducativa", ignore = true)
    @Mapping(target = "gestion", ignore = true)
    TipoPago toEntity(TipoPagoRequestDTO dto);

    @Mapping(target = "idTipoPago", ignore = true)
    @Mapping(target = "unidadEducativa", ignore = true)
    @Mapping(target = "gestion", ignore = true)
    void updateEntityFromDTO(TipoPagoRequestDTO dto, @org.mapstruct.MappingTarget TipoPago entity);
}
