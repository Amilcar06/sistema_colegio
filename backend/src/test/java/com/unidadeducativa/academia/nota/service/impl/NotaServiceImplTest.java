package com.unidadeducativa.academia.nota.service.impl;

import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.academia.asignaciondocente.repository.AsignacionDocenteRepository;
import com.unidadeducativa.academia.nota.dto.NotaRequestDTO;
import com.unidadeducativa.academia.nota.dto.NotaResponseDTO;
import com.unidadeducativa.academia.nota.mapper.NotaMapper;
import com.unidadeducativa.academia.nota.model.Nota;
import com.unidadeducativa.academia.nota.repository.NotaRepository;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.shared.enums.Trimestre;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotaServiceImplTest {

    @Mock
    private NotaRepository notaRepository;

    @Mock
    private NotaMapper notaMapper;

    @Mock
    private EstudianteRepository estudianteRepository;

    @Mock
    private AsignacionDocenteRepository asignacionDocenteRepository;

    @InjectMocks
    private NotaServiceImpl notaService;

    @Test
    void testRegistrarNota_Success() {
        // Arrange
        NotaRequestDTO dto = new NotaRequestDTO();
        dto.setIdEstudiante(1L);
        dto.setIdAsignacion(2L);
        dto.setTrimestre(Trimestre.PRIMER);
        dto.setValor(85.5);

        Estudiante estudiante = new Estudiante();
        AsignacionDocente asignacion = new AsignacionDocente();
        Nota nota = new Nota();
        NotaResponseDTO responseDTO = new NotaResponseDTO();
        responseDTO.setValor(85.5);

        when(estudianteRepository.findById(1L)).thenReturn(Optional.of(estudiante));
        when(asignacionDocenteRepository.findById(2L)).thenReturn(Optional.of(asignacion));
        when(notaRepository.existsByEstudianteAndAsignacionAndTrimestre(estudiante, asignacion, Trimestre.PRIMER))
                .thenReturn(false);
        when(notaMapper.toEntity(dto, estudiante, asignacion)).thenReturn(nota);
        when(notaRepository.save(nota)).thenReturn(nota);
        when(notaMapper.toResponseDTO(nota)).thenReturn(responseDTO);

        // Act
        NotaResponseDTO result = notaService.registrarNota(dto);

        // Assert
        assertNotNull(result);
        assertEquals(85.5, result.getValor());
        verify(notaRepository).save(nota);
    }

    @Test
    void testRegistrarNota_Duplicate() {
        // Arrange
        NotaRequestDTO dto = new NotaRequestDTO();
        dto.setIdEstudiante(1L);
        dto.setIdAsignacion(2L);
        dto.setTrimestre(Trimestre.PRIMER);

        Estudiante estudiante = new Estudiante();
        AsignacionDocente asignacion = new AsignacionDocente();

        when(estudianteRepository.findById(1L)).thenReturn(Optional.of(estudiante));
        when(asignacionDocenteRepository.findById(2L)).thenReturn(Optional.of(asignacion));
        when(notaRepository.existsByEstudianteAndAsignacionAndTrimestre(estudiante, asignacion, Trimestre.PRIMER))
                .thenReturn(true);

        // Act & Assert
        assertThrows(IllegalStateException.class, () -> notaService.registrarNota(dto));
        verify(notaRepository, never()).save(any());
    }

    @Test
    void testRegistrarNota_StudentNotFound() {
        // Arrange
        NotaRequestDTO dto = new NotaRequestDTO();
        dto.setIdEstudiante(99L); // ID doesn't exist

        when(estudianteRepository.findById(99L)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(EntityNotFoundException.class, () -> notaService.registrarNota(dto));
    }
}
