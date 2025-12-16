package com.unidadeducativa.academia.nota.repository;

import com.unidadeducativa.academia.nota.model.Nota;
import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.shared.enums.Trimestre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Map;

public interface NotaRepository extends JpaRepository<Nota, Long> {
  List<Nota> findByEstudiante(Estudiante estudiante);

  List<Nota> findByEstudianteAndTrimestre(Estudiante estudiante, Trimestre trimestre);

  List<Nota> findByAsignacion_IdAsignacion(Long idAsignacion);

  boolean existsByEstudianteAndAsignacionAndTrimestre(Estudiante e, AsignacionDocente a, Trimestre t);

  @Query(value = """
      SELECT
        i.id_estudiante,
        i.id_gestion,
        m.nombre AS materia,
        m.id_materia,
        t.trimestre,
        ad.id_asignacion,
        COALESCE(n.valor, 0) AS valor,
        CONCAT_WS(' ', u.nombres, u.apellido_paterno, u.apellido_materno) AS nombre_profesor
      FROM inscripcion i
      JOIN curso c ON c.id_curso = i.id_curso
      JOIN grado_materia gm ON gm.id_grado = c.id_grado AND gm.id_gestion = i.id_gestion
      JOIN materia m ON m.id_materia = gm.id_materia
      CROSS JOIN (VALUES ('PRIMER'), ('SEGUNDO'), ('TERCER')) AS t(trimestre)
      LEFT JOIN asignacion_docente ad
        ON ad.id_materia = m.id_materia AND ad.id_curso = i.id_curso AND ad.id_gestion = i.id_gestion
      LEFT JOIN nota n
        ON n.id_asignacion = ad.id_asignacion
        AND n.id_estudiante = i.id_estudiante
        AND n.trimestre = t.trimestre
      LEFT JOIN profesor p ON p.id_profesor = ad.id_profesor
      LEFT JOIN usuario u ON u.id_usuario = p.id_usuario
      WHERE i.id_estudiante = :idEstudiante
        AND i.id_gestion = :idGestion
      ORDER BY m.nombre, t.trimestre
      """, nativeQuery = true)
  List<Map<String, Object>> obtenerBoletinCompletoRaw(@Param("idEstudiante") Long idEstudiante,
      @Param("idGestion") Long idGestion);

}
