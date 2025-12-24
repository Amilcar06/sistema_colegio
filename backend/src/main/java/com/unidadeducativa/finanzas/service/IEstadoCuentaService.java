package com.unidadeducativa.finanzas.service;

import com.unidadeducativa.finanzas.dto.EstadoCuentaDTO;
import com.unidadeducativa.usuario.model.Usuario;

public interface IEstadoCuentaService {
    EstadoCuentaDTO obtenerEstadoCuenta(Long idEstudiante, Usuario usuarioAuditor);
}
