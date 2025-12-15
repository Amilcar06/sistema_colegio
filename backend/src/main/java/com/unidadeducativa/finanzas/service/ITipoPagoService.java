package com.unidadeducativa.finanzas.service;

import com.unidadeducativa.finanzas.dto.TipoPagoRequestDTO;
import com.unidadeducativa.finanzas.model.TipoPago;
import com.unidadeducativa.usuario.model.Usuario;

import java.util.List;

public interface ITipoPagoService {
    TipoPago crearTipoPago(TipoPagoRequestDTO request, Usuario usuarioAuditor);

    List<TipoPago> listarPorGestion(Long idGestion, Usuario usuarioAuditor);

    void generarDeudasLote(Long idTipoPago, Usuario usuarioAuditor);

    TipoPago actualizarTipoPago(Long id, TipoPagoRequestDTO request, Usuario usuarioAuditor);

    void eliminarTipoPago(Long id, Usuario usuarioAuditor);
}
