package com.unidadeducativa.academia.paralelo.repository;

import com.unidadeducativa.academia.paralelo.model.ConfiguracionParalelo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConfiguracionParaleloRepository extends JpaRepository<ConfiguracionParalelo, Long> {
    @Query("SELECT c FROM ConfiguracionParalelo c ORDER BY c.orden ASC")
    List<ConfiguracionParalelo> listarTodosOrdenados();
}
