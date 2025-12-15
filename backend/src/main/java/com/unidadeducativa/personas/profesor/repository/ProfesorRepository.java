package com.unidadeducativa.personas.profesor.repository;

import com.unidadeducativa.personas.profesor.model.Profesor;
import com.unidadeducativa.usuario.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProfesorRepository extends JpaRepository<Profesor, Long> {
    List<Profesor> findByUsuario_Estado(boolean estado);

    Optional<Profesor> findByUsuario(Usuario usuario);

    boolean existsByUsuarioCi(String ci);

    Optional<Profesor> findByUsuario_Correo(String correo);
}
