package com.unidadeducativa.personas.profesor.repository;

import com.unidadeducativa.personas.profesor.model.Profesor;
import com.unidadeducativa.usuario.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;
import java.util.Optional;

public interface ProfesorRepository extends JpaRepository<Profesor, Long> {
    Page<Profesor> findByUsuario_Estado(boolean estado, Pageable pageable);

    Optional<Profesor> findByUsuario(Usuario usuario);

    boolean existsByUsuarioCi(String ci);

    Optional<Profesor> findByUsuario_Correo(String correo);
}
