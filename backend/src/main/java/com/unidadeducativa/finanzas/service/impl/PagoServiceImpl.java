package com.unidadeducativa.finanzas.service.impl;

import com.unidadeducativa.finanzas.dto.CuentaCobrarResponseDTO;
import com.unidadeducativa.finanzas.dto.PagoRequestDTO;
import com.unidadeducativa.finanzas.dto.PagoResponseDTO;
import com.unidadeducativa.finanzas.dto.ReporteIngresosDTO;
import com.unidadeducativa.finanzas.mapper.PagoMapper;
import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.finanzas.model.Pago;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.repository.PagoRepository;
import com.unidadeducativa.finanzas.service.IPagoService;
import com.unidadeducativa.shared.enums.EstadoPago;
import com.unidadeducativa.shared.enums.MetodoPago;
import com.unidadeducativa.usuario.model.Usuario;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PagoServiceImpl implements IPagoService {

        private final PagoRepository pagoRepository;
        private final CuentaCobrarRepository cuentaCobrarRepository;
        private final PagoMapper pagoMapper;

        @Override
        @Transactional
        public PagoResponseDTO registrarPago(PagoRequestDTO request, Usuario cajero) {
                CuentaCobrar cuenta = cuentaCobrarRepository.findById(request.getIdCuentaCobrar())
                                .orElseThrow(() -> new RuntimeException("Cuenta por cobrar no encontrada"));

                if (cuenta.getEstado() == EstadoPago.PAGADO || cuenta.getEstado() == EstadoPago.ANULADO) {
                        throw new RuntimeException("La cuenta ya está pagada o anulada");
                }

                if (request.getMontoPagado().compareTo(cuenta.getSaldoPendiente()) > 0) {
                        throw new RuntimeException("El monto a pagar excede el saldo pendiente");
                }

                // Crear Pago
                Pago pago = pagoMapper.toEntity(request);
                pago.setCuentaCobrar(cuenta);
                pago.setCajero(cajero);
                pago.setNumeroRecibo("REC-" + System.currentTimeMillis()); // Simple generador por ahora
                pago = pagoRepository.save(pago);

                // Actualizar Cuenta
                BigDecimal nuevoSaldo = cuenta.getSaldoPendiente().subtract(request.getMontoPagado());
                cuenta.setSaldoPendiente(nuevoSaldo);

                if (nuevoSaldo.compareTo(BigDecimal.ZERO) == 0) {
                        cuenta.setEstado(EstadoPago.PAGADO);
                } else {
                        cuenta.setEstado(EstadoPago.PARCIAL);
                }
                cuentaCobrarRepository.save(cuenta);

                return pagoMapper.toDTO(pago);
        }

        @Override
        public List<CuentaCobrarResponseDTO> listarDeudasEstudiante(Long idEstudiante) {
                return cuentaCobrarRepository.findByEstudiante_IdEstudiante(idEstudiante).stream()
                                .map(cuenta -> CuentaCobrarResponseDTO.builder()
                                                .idCuentaCobrar(cuenta.getIdCuentaCobrar())
                                                .nombreTipoPago(cuenta.getTipoPago().getNombre())
                                                .montoTotal(cuenta.getMonto())
                                                .saldoPendiente(cuenta.getSaldoPendiente())
                                                .estado(cuenta.getEstado())
                                                .fechaVencimiento(cuenta.getFechaVencimiento())
                                                .nombreEstudiante(cuenta.getEstudiante().getUsuario().getNombres() + " "
                                                                + cuenta.getEstudiante().getUsuario()
                                                                                .getApellidoPaterno())
                                                .build())
                                .collect(Collectors.toList());
        }

        @Override
        public List<PagoResponseDTO> listarPagosPorCuenta(Long idCuentaCobrar) {
                return pagoRepository.findByCuentaCobrar_IdCuentaCobrar(idCuentaCobrar).stream()
                                .map(pagoMapper::toDTO)
                                .collect(Collectors.toList());
        }

        @Override
        public List<PagoResponseDTO> listarPagosPorEstudiante(Long idEstudiante) {
                return pagoRepository.findByCuentaCobrar_Estudiante_IdEstudiante(idEstudiante).stream()
                                .map(pagoMapper::toDTO)
                                .collect(Collectors.toList());
        }

        @Override
        public ReporteIngresosDTO generarReporteIngresos(java.time.LocalDate inicio, java.time.LocalDate fin,
                        Usuario auditor) {
                List<Pago> pagos = pagoRepository
                                .findByFechaPagoBetweenAndCuentaCobrar_TipoPago_UnidadEducativa_IdUnidadEducativa(
                                                inicio.atStartOfDay(),
                                                fin.atTime(23, 59, 59),
                                                auditor.getUnidadEducativa().getIdUnidadEducativa());

                BigDecimal total = pagos.stream()
                                .map(Pago::getMontoPagado)
                                .reduce(BigDecimal.ZERO, BigDecimal::add);

                java.util.Map<MetodoPago, BigDecimal> porMetodo = pagos.stream()
                                .collect(Collectors.groupingBy(
                                                Pago::getMetodoPago,
                                                Collectors.reducing(BigDecimal.ZERO, Pago::getMontoPagado,
                                                                BigDecimal::add)));

                return ReporteIngresosDTO.builder()
                                .totalRecaudado(total)
                                .cantidadTransacciones((long) pagos.size())
                                .porMetodoPago(porMetodo)
                                .build();
        }

        @Override
        public List<PagoResponseDTO> listarTodos() {
                return pagoRepository.findAll().stream()
                                .map(pagoMapper::toDTO)
                                .collect(Collectors.toList());
        }
}
