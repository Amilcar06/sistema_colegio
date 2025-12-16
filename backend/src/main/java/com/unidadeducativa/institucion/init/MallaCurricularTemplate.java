package com.unidadeducativa.institucion.init;

import com.unidadeducativa.shared.enums.TipoNivel;
import lombok.Getter;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class MallaCurricularTemplate {

        @Getter
        public static final Map<String, GradeDefinition> MALLA_BASE = new TreeMap<>();

        static {
                // PRIMARIA
                add("1_PRIMARIA", "PRIMERO", TipoNivel.PRIMARIA,
                                "Ciencias Naturales", "Comunicación y Lenguajes", "Ciencias Sociales",
                                "Artes Plásticas y Visuales", "Educación Física y Deportes", "Educación Musical",
                                "Matemáticas", "Técnica Tecnológica", "Valores Espirituales y Religiones");

                add("2_PRIMARIA", "SEGUNDO", TipoNivel.PRIMARIA,
                                "Ciencias Naturales", "Comunicación y Lenguajes", "Ciencias Sociales",
                                "Artes Plásticas y Visuales", "Educación Física y Deportes", "Educación Musical",
                                "Matemáticas", "Técnica Tecnológica", "Valores Espirituales y Religiones");

                add("3_PRIMARIA", "TERCERO", TipoNivel.PRIMARIA,
                                "Ciencias Naturales", "Comunicación y Lenguajes", "Ciencias Sociales",
                                "Artes Plásticas y Visuales", "Educación Física y Deportes", "Educación Musical",
                                "Matemáticas", "Técnica Tecnológica", "Valores Espirituales y Religiones");

                add("4_PRIMARIA", "CUARTO", TipoNivel.PRIMARIA,
                                "Ciencias Naturales", "Comunicación y Lenguajes", "Ciencias Sociales",
                                "Artes Plásticas y Visuales", "Educación Física y Deportes", "Educación Musical",
                                "Matemáticas", "Técnica Tecnológica", "Valores Espirituales y Religiones");

                add("5_PRIMARIA", "QUINTO", TipoNivel.PRIMARIA,
                                "Ciencias Naturales", "Comunicación y Lenguajes", "Ciencias Sociales",
                                "Artes Plásticas y Visuales", "Educación Física y Deportes", "Educación Musical",
                                "Matemáticas", "Técnica Tecnológica", "Valores Espirituales y Religiones");

                add("6_PRIMARIA", "SEXTO", TipoNivel.PRIMARIA,
                                "Ciencias Naturales", "Comunicación y Lenguajes", "Ciencias Sociales",
                                "Artes Plásticas y Visuales", "Educación Física y Deportes", "Educación Musical",
                                "Matemáticas", "Técnica Tecnológica", "Valores Espirituales y Religiones");

                // SECUNDARIA
                add("1_SECUNDARIA", "PRIMERO", TipoNivel.SECUNDARIA,
                                "Biología - Geografía", "Lengua Castellana y Originaria", "Lengua Extranjera",
                                "Ciencias Sociales", "Educación Física y Deportes", "Educación Musical",
                                "Artes Plásticas y Visuales", "Cosmovisiones, Filosofía y Psicología",
                                "Valores, Espiritualidades y Religiones", "Matemáticas", "Técnica Tecnológica General");

                add("2_SECUNDARIA", "SEGUNDO", TipoNivel.SECUNDARIA,
                                "Biología - Geografía", "Lengua Castellana y Originaria", "Lengua Extranjera",
                                "Ciencias Sociales", "Educación Física y Deportes", "Educación Musical",
                                "Artes Plásticas y Visuales", "Cosmovisiones, Filosofía y Psicología",
                                "Valores, Espiritualidades y Religiones", "Matemáticas", "Técnica Tecnológica General");

                add("3_SECUNDARIA", "TERCERO", TipoNivel.SECUNDARIA,
                                "Biología - Geografía", "Física", "Química", "Lengua Castellana y Originaria",
                                "Lengua Extranjera", "Ciencias Sociales", "Educación Física y Deportes",
                                "Educación Musical", "Artes Plásticas y Visuales",
                                "Cosmovisiones, Filosofía y Psicología",
                                "Valores, Espiritualidades y Religiones", "Matemáticas",
                                "Técnica Tecnológica Especializada");

                add("4_SECUNDARIA", "CUARTO", TipoNivel.SECUNDARIA,
                                "Biología - Geografía", "Física", "Química", "Lengua Castellana y Originaria",
                                "Lengua Extranjera", "Ciencias Sociales", "Educación Física y Deportes",
                                "Educación Musical", "Artes Plásticas y Visuales",
                                "Cosmovisiones, Filosofía y Psicología",
                                "Valores, Espiritualidades y Religiones", "Matemáticas",
                                "Técnica Tecnológica Especializada");

                add("5_SECUNDARIA", "QUINTO", TipoNivel.SECUNDARIA,
                                "Biología - Geografía", "Física", "Química", "Lengua Castellana y Originaria",
                                "Lengua Extranjera", "Ciencias Sociales", "Educación Física y Deportes",
                                "Educación Musical", "Artes Plásticas y Visuales",
                                "Cosmovisiones, Filosofía y Psicología",
                                "Valores, Espiritualidades y Religiones", "Matemáticas",
                                "Técnica Tecnológica Especializada");

                add("6_SECUNDARIA", "SEXTO", TipoNivel.SECUNDARIA,
                                "Biología - Geografía", "Física", "Química", "Lengua Castellana y Originaria",
                                "Lengua Extranjera", "Ciencias Sociales", "Educación Física y Deportes",
                                "Educación Musical", "Artes Plásticas y Visuales",
                                "Cosmovisiones, Filosofía y Psicología",
                                "Valores, Espiritualidades y Religiones", "Matemáticas",
                                "Técnica Tecnológica Especializada");
        }

        private static void add(String key, String nombreGrado, TipoNivel nivel, String... materias) {
                MALLA_BASE.put(key, new GradeDefinition(nombreGrado, nivel, Arrays.asList(materias)));
        }

        public record GradeDefinition(String nombreGrado, TipoNivel nivel, List<String> materias) {
        }
}
