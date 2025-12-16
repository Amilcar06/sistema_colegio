package com.unidadeducativa.usuario.repository;

import com.unidadeducativa.usuario.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByCorreo(String correo);

    boolean existsByCorreo(String correo);

    boolean existsByCi(String ci);

    // Scoped methods
    List<Usuario> findAllByUnidadEducativa_IdUnidadEducativa(Long idUnidadEducativa);

    boolean existsByCiAndUnidadEducativa_IdUnidadEducativa(String ci, Long idUnidadEducativa);

    long countByRol_Nombre(com.unidadeducativa.shared.enums.RolNombre nombre);
}
