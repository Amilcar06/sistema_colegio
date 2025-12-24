package com.unidadeducativa.academia.paralelo.service;

import lombok.extern.slf4j.Slf4j;
import com.unidadeducativa.academia.paralelo.dto.ConfiguracionParaleloDTO;
import com.unidadeducativa.academia.paralelo.model.ConfiguracionParalelo;
import com.unidadeducativa.academia.paralelo.repository.ConfiguracionParaleloRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ConfiguracionParaleloService {

    private final ConfiguracionParaleloRepository repository;

    @Transactional(readOnly = true)
    public List<ConfiguracionParaleloDTO> listarTodos() {
        try {
            return repository.listarTodosOrdenados().stream()
                    .map(this::mapToDTO)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Error al listar paralelos", e);
            throw e;
        }
    }

    @Transactional
    public ConfiguracionParaleloDTO cambiarEstado(Long id, Boolean activo) {
        ConfiguracionParalelo entidad = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Paralelo no encontrado: " + id));
        entidad.setActivo(activo);
        ConfiguracionParalelo saved = repository.save(entidad);
        return mapToDTO(saved);
    }

    @PostConstruct
    @Transactional
    public void seedInicial() {
        if (repository.count() == 0) {
            crearParalelo("A", 1);
            crearParalelo("B", 2);
            crearParalelo("C", 3);
            crearParalelo("D", 4);
            crearParalelo("E", 5);
        }
    }

    private void crearParalelo(String nombre, int orden) {
        ConfiguracionParalelo p = ConfiguracionParalelo.builder()
                .nombre(nombre)
                .activo(true)
                .orden(orden)
                .build();
        repository.save(p);
    }

    private ConfiguracionParaleloDTO mapToDTO(ConfiguracionParalelo entidad) {
        return ConfiguracionParaleloDTO.builder()
                .id(entidad.getId())
                .nombre(entidad.getNombre())
                .activo(entidad.getActivo())
                .orden(entidad.getOrden())
                .build();
    }
}
