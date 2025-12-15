package com.unidadeducativa.personas.secretaria.repository;

import com.unidadeducativa.personas.secretaria.model.Secretaria;
import com.unidadeducativa.usuario.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SecretariaRepository extends JpaRepository<Secretaria, Long> {
    boolean existsByUsuarioCi(String ci);
    Optional<Secretaria> findByUsuario(Usuario usuario);
    List<Secretaria> findByUsuarioEstado(Boolean estado);
}
