package com.unidadeducativa.finanzas.service;

import com.unidadeducativa.finanzas.dto.CuentaCobrarResponseDTO;
import com.unidadeducativa.finanzas.dto.PagoRequestDTO;
import com.unidadeducativa.finanzas.dto.PagoResponseDTO;
import com.unidadeducativa.finanzas.dto.ReporteIngresosDTO;
import com.unidadeducativa.usuario.model.Usuario;

import java.util.List;

public interface IPagoService {
    PagoResponseDTO registrarPago(PagoRequestDTO request, Usuario cajero);

    List<CuentaCobrarResponseDTO> listarDeudasEstudiante(Long idEstudiante);

    List<PagoResponseDTO> listarPagosPorCuenta(Long idCuentaCobrar);

    List<PagoResponseDTO> listarPagosPorEstudiante(Long idEstudiante);

    ReporteIngresosDTO generarReporteIngresos(java.time.LocalDate inicio, java.time.LocalDate fin, Usuario auditor);
}
