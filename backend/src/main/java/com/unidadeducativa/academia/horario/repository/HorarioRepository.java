package com.unidadeducativa.academia.horario.repository;

import com.unidadeducativa.academia.horario.model.Horario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface HorarioRepository extends JpaRepository<Horario, Long> {

        List<Horario> findByAsignacionDocenteIdAsignacion(Long idAsignacion);

        // Listar horarios de un curso entero (para validar choques o ver agenda del
        // estudiante)
        @Query("SELECT h FROM Horario h WHERE h.asignacionDocente.curso.idCurso = :idCurso ORDER BY h.diaSemana, h.horaInicio")
        List<Horario> findByCurso(@Param("idCurso") Long idCurso);

        // Listar horarios de un profesor (para validar choques o ver agenda del profe)
        @Query("SELECT h FROM Horario h WHERE h.asignacionDocente.profesor.idProfesor = :idProfesor ORDER BY h.diaSemana, h.horaInicio")
        List<Horario> findByProfesor(@Param("idProfesor") Long idProfesor);

        // Detección de solapamiento para Profesor
        @Query("SELECT COUNT(h) FROM Horario h WHERE " +
                        "h.asignacionDocente.profesor.idProfesor = :idProfesor AND " +
                        "h.diaSemana = :diaSemana AND " +
                        "((h.horaInicio < :horaFin) AND (h.horaFin > :horaInicio))")
        long countOverlappingProfesor(
                        @Param("idProfesor") Long idProfesor,
                        @Param("diaSemana") com.unidadeducativa.academia.horario.model.DiaSemana diaSemana,
                        @Param("horaInicio") java.time.LocalTime horaInicio,
                        @Param("horaFin") java.time.LocalTime horaFin);

        // Detección de solapamiento para Curso
        @Query("SELECT COUNT(h) FROM Horario h WHERE " +
                        "h.asignacionDocente.curso.idCurso = :idCurso AND " +
                        "h.diaSemana = :diaSemana AND " +
                        "((h.horaInicio < :horaFin) AND (h.horaFin > :horaInicio))")
        long countOverlappingCurso(
                        @Param("idCurso") Long idCurso,
                        @Param("diaSemana") com.unidadeducativa.academia.horario.model.DiaSemana diaSemana,
                        @Param("horaInicio") java.time.LocalTime horaInicio,
                        @Param("horaFin") java.time.LocalTime horaFin);

        // Detección de solapamiento para Aula (Opcional, pero bueno tenerlo)
        @Query("SELECT COUNT(h) FROM Horario h WHERE " +
                        "h.aula = :aula AND " +
                        "h.diaSemana = :diaSemana AND " +
                        "((h.horaInicio < :horaFin) AND (h.horaFin > :horaInicio))")
        long countOverlappingAula(
                        @Param("aula") String aula,
                        @Param("diaSemana") com.unidadeducativa.academia.horario.model.DiaSemana diaSemana,
                        @Param("horaInicio") java.time.LocalTime horaInicio,
                        @Param("horaFin") java.time.LocalTime horaFin);
}
