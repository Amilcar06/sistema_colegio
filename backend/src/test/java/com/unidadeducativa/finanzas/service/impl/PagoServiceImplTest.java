package com.unidadeducativa.finanzas.service.impl;

import com.unidadeducativa.finanzas.dto.PagoRequestDTO;
import com.unidadeducativa.finanzas.dto.PagoResponseDTO;
import com.unidadeducativa.finanzas.mapper.PagoMapper;
import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.finanzas.model.Pago;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.repository.PagoRepository;
import com.unidadeducativa.shared.enums.EstadoPago;
import com.unidadeducativa.usuario.model.Usuario;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PagoServiceImplTest {

    @Mock
    private PagoRepository pagoRepository;

    @Mock
    private CuentaCobrarRepository cuentaCobrarRepository;

    @Mock
    private PagoMapper pagoMapper;

    @InjectMocks
    private PagoServiceImpl pagoService;

    @Test
    void testRegistrarPago_Success_Full() {
        // Arrange
        PagoRequestDTO request = new PagoRequestDTO();
        request.setIdCuentaCobrar(1L);
        request.setMontoPagado(new BigDecimal("100.00"));

        Usuario cajero = new Usuario();

        CuentaCobrar cuenta = new CuentaCobrar();
        cuenta.setIdCuentaCobrar(1L);
        cuenta.setMonto(new BigDecimal("100.00"));
        cuenta.setSaldoPendiente(new BigDecimal("100.00"));
        cuenta.setEstado(EstadoPago.PENDIENTE);

        Pago pago = new Pago();
        PagoResponseDTO responseDTO = new PagoResponseDTO();
        responseDTO.setIdPago(1L);

        when(cuentaCobrarRepository.findById(1L)).thenReturn(Optional.of(cuenta));
        when(pagoMapper.toEntity(request)).thenReturn(pago);
        when(pagoRepository.save(any(Pago.class))).thenReturn(pago);
        when(pagoMapper.toDTO(pago)).thenReturn(responseDTO);

        // Act
        PagoResponseDTO result = pagoService.registrarPago(request, cajero);

        // Assert
        assertNotNull(result);
        assertEquals(EstadoPago.PAGADO, cuenta.getEstado());
        assertEquals(0, BigDecimal.ZERO.compareTo(cuenta.getSaldoPendiente()));
        verify(cuentaCobrarRepository).save(cuenta);
    }

    @Test
    void testRegistrarPago_Success_Partial() {
        // Arrange
        PagoRequestDTO request = new PagoRequestDTO();
        request.setIdCuentaCobrar(1L);
        request.setMontoPagado(new BigDecimal("50.00"));

        Usuario cajero = new Usuario();

        CuentaCobrar cuenta = new CuentaCobrar();
        cuenta.setIdCuentaCobrar(1L);
        cuenta.setMonto(new BigDecimal("100.00"));
        cuenta.setSaldoPendiente(new BigDecimal("100.00"));
        cuenta.setEstado(EstadoPago.PENDIENTE);

        Pago pago = new Pago();
        PagoResponseDTO responseDTO = new PagoResponseDTO();

        when(cuentaCobrarRepository.findById(1L)).thenReturn(Optional.of(cuenta));
        when(pagoMapper.toEntity(request)).thenReturn(pago);
        when(pagoRepository.save(any(Pago.class))).thenReturn(pago);
        when(pagoMapper.toDTO(pago)).thenReturn(responseDTO);

        // Act
        pagoService.registrarPago(request, cajero);

        // Assert
        assertEquals(EstadoPago.PARCIAL, cuenta.getEstado());
        assertEquals(0, new BigDecimal("50.00").compareTo(cuenta.getSaldoPendiente()));
        verify(cuentaCobrarRepository).save(cuenta);
    }

    @Test
    void testRegistrarPago_ExceedsBalance() {
        // Arrange
        PagoRequestDTO request = new PagoRequestDTO();
        request.setIdCuentaCobrar(1L);
        request.setMontoPagado(new BigDecimal("200.00")); // Owed is 100

        CuentaCobrar cuenta = new CuentaCobrar();
        cuenta.setSaldoPendiente(new BigDecimal("100.00"));

        when(cuentaCobrarRepository.findById(1L)).thenReturn(Optional.of(cuenta));

        // Act & Assert
        assertThrows(RuntimeException.class, () -> pagoService.registrarPago(request, new Usuario()));
        verify(pagoRepository, never()).save(any());
    }
}
