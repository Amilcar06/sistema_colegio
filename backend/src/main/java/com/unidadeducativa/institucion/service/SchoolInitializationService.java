package com.unidadeducativa.institucion.service;

import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.gestion.repository.GestionRepository;
import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.academia.grado.repository.GradoRepository;
import com.unidadeducativa.academia.gradomateria.model.GradoMateria;
import com.unidadeducativa.academia.gradomateria.repository.GradoMateriaRepository;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.materia.repository.MateriaRepository;
import com.unidadeducativa.institucion.init.MallaCurricularTemplate;
import com.unidadeducativa.institucion.model.UnidadEducativa;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
@Slf4j
public class SchoolInitializationService {

    private final GestionRepository gestionRepository;
    private final GradoRepository gradoRepository;
    private final MateriaRepository materiaRepository;
    private final GradoMateriaRepository gradoMateriaRepository;

    @Transactional
    public void initializeSchool(UnidadEducativa unidadEducativa) {
        log.info("Iniciando configuración automática para Unidad Educativa: {}", unidadEducativa.getNombre());

        // 1. Crear Gestión Académica Actual (ej. 2025)
        int currentYear = LocalDate.now().getYear();
        GestionAcademica gestion = gestionRepository
                .findByAnioAndUnidadEducativa_IdUnidadEducativa(currentYear, unidadEducativa.getIdUnidadEducativa())
                .orElseGet(() -> {
                    GestionAcademica g = GestionAcademica.builder()
                            .anio(currentYear)
                            .unidadEducativa(unidadEducativa)
                            .estado(true)
                            .build();
                    return gestionRepository.save(g);
                });

        // 2. Cargar Malla Curricular Base
        MallaCurricularTemplate.MALLA_BASE.forEach((key, def) -> {
            // 2.1 Buscar o Crear Grado Global
            Grado grado = gradoRepository.findByNombreAndNivel(def.nombreGrado(), def.nivel())
                    .orElseGet(() -> gradoRepository.save(Grado.builder()
                            .nombre(def.nombreGrado())
                            .nivel(def.nivel())
                            .build()));

            // 2.2 Crear Materias y Asignarlas
            for (String nombreMateria : def.materias()) {
                // Verificar si la materia ya existe para esta UE (para no duplicar si se corre
                // 2 veces)
                // Nota: Buscamos por nombre, pero podría haber homónimos en distintos grados.
                // Sin embargo, Materia es una entidad que representa el contenido.
                // Si "Matemáticas" se da en 1ro y 2do, ¿es la misma entidad o distinta?
                // En el modelo "GradoMateria", la Materia DEBERÍA ser reutilizable si es
                // "Matemáticas General",
                // pero si el contenido varía drásticamente (Matemática 1 vs Matemática 2),
                // deberían ser distintas.
                // En la malla dada, se repite el nombre "Matemáticas".
                // Estrategia: Crear Materia única por Nombre por UE y reutilizarla en
                // GradoMateria.

                Materia materia = materiaRepository
                        .findAllByUnidadEducativa_IdUnidadEducativa(unidadEducativa.getIdUnidadEducativa())
                        .stream()
                        .filter(m -> m.getNombre().equalsIgnoreCase(nombreMateria))
                        .findFirst()
                        .orElseGet(() -> materiaRepository.save(Materia.builder()
                                .nombre(nombreMateria)
                                .unidadEducativa(unidadEducativa)
                                .build()));

                // 2.3 Crear Relación Grado-Materia-Gestion
                boolean exists = gradoMateriaRepository.existsByGradoAndMateriaAndGestion(grado, materia, gestion);
                if (!exists) {
                    gradoMateriaRepository.save(GradoMateria.builder()
                            .grado(grado)
                            .materia(materia)
                            .gestion(gestion)
                            .build());
                }
            }
        });

        log.info("Configuración completada para UE: {}", unidadEducativa.getNombre());
    }
}
