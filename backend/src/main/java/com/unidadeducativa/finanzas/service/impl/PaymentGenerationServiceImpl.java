package com.unidadeducativa.finanzas.service.impl;

import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;
import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.finanzas.model.TipoPago;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.service.PaymentGenerationService;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.shared.enums.EstadoInscripcion;
import com.unidadeducativa.shared.enums.EstadoPago;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentGenerationServiceImpl implements PaymentGenerationService {

    private final InscripcionRepository inscripcionRepository;
    private final CuentaCobrarRepository cuentaCobrarRepository;

    @Override
    @Transactional
    public void generarDeudaMasiva(TipoPago tipoPago) {
        log.info("Generando deudas masivas para concepto: {}", tipoPago.getNombre());

        if (!tipoPago.isEsObligatorio()) {
            log.warn("El tipo de pago {} no es obligatorio. Se omite generación.", tipoPago.getNombre());
            return;
        }

        // Buscar inscripciones activas en la gestion del pago
        List<Inscripcion> inscripciones = inscripcionRepository.findByGestionAndEstado(
                tipoPago.getGestion(),
                EstadoInscripcion.ACTIVO);

        int count = 0;
        for (Inscripcion inscripcion : inscripciones) {
            Estudiante estudiante = inscripcion.getEstudiante();

            if (!cuentaCobrarRepository.existsByEstudianteAndTipoPago(estudiante, tipoPago)) {
                // Calcular fecha vencimiento.
                LocalDate vencimiento = tipoPago.getFechaLimite();
                if (vencimiento == null) {
                    vencimiento = LocalDate.now().plusDays(30);
                }

                cuentaCobrarRepository.save(CuentaCobrar.builder()
                        .estudiante(estudiante)
                        .tipoPago(tipoPago)
                        .monto(tipoPago.getMontoDefecto())
                        .saldoPendiente(tipoPago.getMontoDefecto())
                        .fechaVencimiento(vencimiento)
                        .estado(EstadoPago.PENDIENTE)
                        .build());
                count++;
            }
        }
        log.info("Se generaron {} cuentas por cobrar para {}", count, tipoPago.getNombre());
    }
}
