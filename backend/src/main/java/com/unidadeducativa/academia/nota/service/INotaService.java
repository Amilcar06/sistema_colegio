package com.unidadeducativa.academia.nota.service;

import com.unidadeducativa.academia.nota.dto.NotaRequestDTO;
import com.unidadeducativa.academia.nota.dto.NotaBulkRequestDTO;
import com.unidadeducativa.academia.nota.dto.NotaResponseDTO;
import com.unidadeducativa.academia.nota.dto.NotaBoletinDTO;
import com.unidadeducativa.academia.nota.dto.LibretaDigitalDTO;
import com.unidadeducativa.shared.enums.Trimestre;

import java.util.List;

public interface INotaService {
    NotaResponseDTO registrarNota(NotaRequestDTO dto);

    void registrarNotasMasivas(NotaBulkRequestDTO bulk);

    NotaResponseDTO actualizarNota(Long idNota, NotaRequestDTO dto);

    void eliminarNota(Long idNota);

    List<NotaResponseDTO> obtenerNotasPorEstudiante(Long idEstudiante);

    List<NotaResponseDTO> obtenerNotasPorEstudianteYTrimestre(Long idEstudiante, Trimestre trimestre);

    NotaBoletinDTO obtenerBoletin(Long idEstudiante, Long idGestion);

    LibretaDigitalDTO obtenerLibreta(Long idAsignacion);

    List<com.unidadeducativa.academia.nota.dto.BoletinNotasDTO> obtenerBoletinCurso(Long idAsignacion,
            Trimestre trimestre);

    void guardarNotasBatch(List<com.unidadeducativa.academia.nota.dto.BoletinNotasDTO> notas, Long idAsignacion,
            Trimestre trimestre);
}
