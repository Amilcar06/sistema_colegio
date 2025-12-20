package com.unidadeducativa.finanzas.mapper;

import com.unidadeducativa.finanzas.dto.PagoRequestDTO;
import com.unidadeducativa.finanzas.dto.PagoResponseDTO;
import com.unidadeducativa.finanzas.model.Pago;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface PagoMapper {
    @Mapping(target = "idPago", ignore = true)
    @Mapping(target = "cuentaCobrar", ignore = true)
    @Mapping(target = "fechaPago", ignore = true)
    @Mapping(target = "numeroRecibo", ignore = true)
    @Mapping(target = "cajero", ignore = true)
    Pago toEntity(PagoRequestDTO dto);

    @Mapping(source = "cuentaCobrar.idCuentaCobrar", target = "idCuentaCobrar")
    @Mapping(source = "cuentaCobrar.tipoPago.nombre", target = "concepto")
    @Mapping(target = "nombreCajero", expression = "java(mapNombreCajero(entity))")
    PagoResponseDTO toDTO(Pago entity);

    default String mapNombreCajero(Pago entity) {
        if (entity.getCajero() != null) {
            return entity.getCajero().getNombres() + " " + entity.getCajero().getApellidoPaterno();
        }
        return null;
    }
}
