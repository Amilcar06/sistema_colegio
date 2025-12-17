package com.unidadeducativa.comunicacion.repository;

import com.unidadeducativa.comunicacion.model.Evento;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface EventoRepository extends JpaRepository<Evento, Long> {
    List<Evento> findAllByFechaInicioAfterOrderByFechaInicioAsc(LocalDateTime fecha);
}
