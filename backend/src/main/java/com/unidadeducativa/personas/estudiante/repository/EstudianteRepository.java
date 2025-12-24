package com.unidadeducativa.personas.estudiante.repository;

import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.usuario.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;
import java.util.Optional;

@Repository
public interface EstudianteRepository extends JpaRepository<Estudiante, Long> {
    boolean existsByUsuarioCi(String ci);

    Optional<Estudiante> findByUsuario(Usuario usuario);

    Page<Estudiante> findByUsuarioEstado(Boolean estado, Pageable pageable);

    List<Estudiante> findByUsuario_UnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);
}
