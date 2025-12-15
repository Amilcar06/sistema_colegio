package com.unidadeducativa.academia.horario.service;

import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.academia.asignaciondocente.repository.AsignacionDocenteRepository;
import com.unidadeducativa.academia.horario.dto.HorarioRequestDTO;
import com.unidadeducativa.academia.horario.dto.HorarioResponseDTO;
import com.unidadeducativa.academia.horario.model.Horario;
import com.unidadeducativa.academia.horario.repository.HorarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HorarioService {

    private final HorarioRepository horarioRepository;
    private final AsignacionDocenteRepository asignacionRepository;

    @Transactional
    public HorarioResponseDTO crear(HorarioRequestDTO dto) {
        // 1. Buscar Asignación
        AsignacionDocente asignacion = asignacionRepository.findById(dto.getIdAsignacion())
                .orElseThrow(() -> new RuntimeException("Asignación docente no encontrada"));

        // 2. TODO: Validar choques de horario (Profesor y Curso)

        Horario horario = Horario.builder()
                .asignacionDocente(asignacion)
                .diaSemana(dto.getDiaSemana())
                .horaInicio(dto.getHoraInicio())
                .horaFin(dto.getHoraFin())
                .aula(dto.getAula())
                .build();

        return mapToDTO(horarioRepository.save(horario));
    }

    @Transactional(readOnly = true)
    public List<HorarioResponseDTO> listarPorCurso(Long idCurso) {
        return horarioRepository.findByCurso(idCurso).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<HorarioResponseDTO> listarPorProfesor(Long idProfesor) {
        return horarioRepository.findByProfesor(idProfesor).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void eliminar(Long idHorario) {
        horarioRepository.deleteById(idHorario);
    }

    private HorarioResponseDTO mapToDTO(Horario h) {
        return HorarioResponseDTO.builder()
                .idHorario(h.getIdHorario())
                .idAsignacion(h.getAsignacionDocente().getIdAsignacion())
                .nombreMateria(h.getAsignacionDocente().getMateria().getNombre())
                .nombreProfesor(h.getAsignacionDocente().getProfesor().getUsuario().getNombreCompleto())
                .nombreCurso(h.getAsignacionDocente().getCurso().getGrado().getNombre() + " "
                        + h.getAsignacionDocente().getCurso().getParalelo())
                .diaSemana(h.getDiaSemana())
                .horaInicio(h.getHoraInicio())
                .horaFin(h.getHoraFin())
                .aula(h.getAula())
                .build();
    }
}
