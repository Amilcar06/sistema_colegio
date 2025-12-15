package com.unidadeducativa.academia.grado.repository;

import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.shared.enums.TipoNivel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GradoRepository extends JpaRepository<Grado, Long> {
    boolean existsByNombre(String nombre);

    Optional<Grado> findByNombreAndNivel(String nombre, TipoNivel nivel);

    List<Grado> findByNivel(TipoNivel nivel);

}
