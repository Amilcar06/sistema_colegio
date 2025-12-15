package com.unidadeducativa.academia.curso.repository;

import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.shared.enums.TipoTurno;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CursoRepository extends JpaRepository<Curso, Long> {
    boolean existsByGrado_IdGradoAndParaleloAndTurno(Long idGrado, String paralelo, TipoTurno turno);
}
