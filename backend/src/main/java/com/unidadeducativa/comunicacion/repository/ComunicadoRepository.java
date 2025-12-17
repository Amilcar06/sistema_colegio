package com.unidadeducativa.comunicacion.repository;

import com.unidadeducativa.comunicacion.enums.TipoDestinatario;
import com.unidadeducativa.comunicacion.model.Comunicado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ComunicadoRepository extends JpaRepository<Comunicado, Long> {

    // Find global announcements
    List<Comunicado> findByTipoDestinatario(TipoDestinatario tipoDestinatario);

    // Find by course (and also need to verify logic later if we want mixed)
    List<Comunicado> findByTipoDestinatarioAndIdReferencia(TipoDestinatario tipoDestinatario, Long idReferencia);

    // Example custom query to fetch Global OR Specific Course announcements for a
    // student
    @Query("SELECT c FROM Comunicado c WHERE c.tipoDestinatario = 'TODOS' OR (c.tipoDestinatario = 'POR_CURSO' AND c.idReferencia = :idCurso)")
    List<Comunicado> findGlobalOrPorCurso(@Param("idCurso") Long idCurso);
}
