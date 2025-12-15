package com.unidadeducativa.academia.grado.model;

import com.unidadeducativa.shared.enums.TipoNivel;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "grado")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Grado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_grado")
    private Long idGrado;

    @Column(name = "nombre", nullable = false, length = 20)
    private String nombre;

    @Enumerated(EnumType.STRING)
    @Column(name = "nivel", nullable = false)
    private TipoNivel nivel;
}
