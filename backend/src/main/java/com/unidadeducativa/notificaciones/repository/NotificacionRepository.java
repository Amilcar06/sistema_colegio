package com.unidadeducativa.notificaciones.repository;

import com.unidadeducativa.notificaciones.model.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificacionRepository extends JpaRepository<Notificacion, Long> {
    List<Notificacion> findByUsuarioIdUsuarioOrderByFechaCreacionDesc(Long idUsuario);

    long countByUsuarioIdUsuarioAndLeidoFalse(Long idUsuario);
}
