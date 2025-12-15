package com.unidadeducativa.personas.director.repository;

import com.unidadeducativa.personas.director.model.Director;
import com.unidadeducativa.usuario.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DirectorRepository extends JpaRepository<Director, Long> {
    boolean existsByUsuarioCi(String ci);
    Optional<Director> findByUsuario(Usuario usuario);
    List<Director> findByUsuarioEstado(Boolean estado);
}
