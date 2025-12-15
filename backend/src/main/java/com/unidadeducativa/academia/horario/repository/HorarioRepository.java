package com.unidadeducativa.academia.horario.repository;

import com.unidadeducativa.academia.horario.model.Horario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface HorarioRepository extends JpaRepository<Horario, Long> {

    List<Horario> findByAsignacionDocenteIdAsignacion(Long idAsignacion);

    // Listar horarios de un curso entero (para validar choques o ver agenda del
    // alumno)
    @Query("SELECT h FROM Horario h WHERE h.asignacionDocente.curso.idCurso = :idCurso ORDER BY h.diaSemana, h.horaInicio")
    List<Horario> findByCurso(@Param("idCurso") Long idCurso);

    // Listar horarios de un profesor (para validar choques o ver agenda del profe)
    @Query("SELECT h FROM Horario h WHERE h.asignacionDocente.profesor.idProfesor = :idProfesor ORDER BY h.diaSemana, h.horaInicio")
    List<Horario> findByProfesor(@Param("idProfesor") Long idProfesor);
}
