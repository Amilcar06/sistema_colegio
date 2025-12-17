package com.unidadeducativa.comunicacion.service;

import com.unidadeducativa.comunicacion.dto.EventoRequestDTO;
import com.unidadeducativa.comunicacion.dto.EventoResponseDTO;
import com.unidadeducativa.comunicacion.model.Evento;
import com.unidadeducativa.comunicacion.repository.EventoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EventoService {

    private final EventoRepository eventoRepository;

    public EventoResponseDTO crearEvento(EventoRequestDTO request) {
        Evento evento = Evento.builder()
                .titulo(request.getTitulo())
                .descripcion(request.getDescripcion())
                .fechaInicio(request.getFechaInicio())
                .fechaFin(request.getFechaFin())
                .ubicacion(request.getUbicacion())
                .tipoEvento(request.getTipoEvento())
                .build();

        Evento saved = eventoRepository.save(evento);
        return mapToDTO(saved);
    }

    public List<EventoResponseDTO> listarProximosEventos() {
        // Listar eventos cuya fecha de inicio sea hoy o futuro
        LocalDateTime hoy = LocalDateTime.now().withHour(0).withMinute(0);
        return eventoRepository.findAllByFechaInicioAfterOrderByFechaInicioAsc(hoy).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private EventoResponseDTO mapToDTO(Evento e) {
        return EventoResponseDTO.builder()
                .idEvento(e.getIdEvento())
                .titulo(e.getTitulo())
                .descripcion(e.getDescripcion())
                .fechaInicio(e.getFechaInicio())
                .fechaFin(e.getFechaFin())
                .ubicacion(e.getUbicacion())
                .tipoEvento(e.getTipoEvento())
                .build();
    }
}
