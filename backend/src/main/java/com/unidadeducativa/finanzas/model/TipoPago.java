package com.unidadeducativa.finanzas.model;

import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.institucion.model.UnidadEducativa;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "tipo_pago")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TipoPago {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_tipo_pago")
    private Long idTipoPago;

    @Column(nullable = false, length = 100)
    private String nombre; // Ej. "Mensualidad Marzo"

    @Column(name = "monto_defecto", nullable = false, precision = 10, scale = 2)
    private BigDecimal montoDefecto;

    @Column(name = "fecha_limite")
    private LocalDate fechaLimite;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_unidad_educativa", nullable = true)
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
    private UnidadEducativa unidadEducativa;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_gestion", nullable = false)
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
    private GestionAcademica gestion;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private com.unidadeducativa.shared.enums.CategoriaPago categoria = com.unidadeducativa.shared.enums.CategoriaPago.OTRO;

    @Column(name = "es_obligatorio", nullable = false)
    @Builder.Default
    private boolean esObligatorio = false;
}
