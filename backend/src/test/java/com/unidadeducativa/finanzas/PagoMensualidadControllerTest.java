package com.unidadeducativa.finanzas;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.unidadeducativa.BaseIntegrationTest;
import com.unidadeducativa.finanzas.dto.PagoRequestDTO;
import com.unidadeducativa.finanzas.dto.PagoResponseDTO;
import com.unidadeducativa.finanzas.service.IPagoService;
import com.unidadeducativa.shared.enums.MetodoPago;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class PagoMensualidadControllerTest extends BaseIntegrationTest {

        @Autowired
        private MockMvc mockMvc;

        @MockBean
        private IPagoService pagoService;

        @Autowired
        private UsuarioRepository usuarioRepository;

        @Autowired
        private ObjectMapper objectMapper;

        @BeforeEach
        void setUp() {
                // DataInitializer creates 'secretaria@gmail.com' which we use in tests
        }

        @Test
        @WithMockUser(username = "secretaria@gmail.com", roles = "SECRETARIA")
        void registrarPago_DeberiaRetornar200_CuandoDatosSonValidos() throws Exception {
                PagoRequestDTO request = PagoRequestDTO.builder()
                                .idCuentaCobrar(10L)
                                .montoPagado(new BigDecimal("150.00"))
                                .metodoPago(MetodoPago.EFECTIVO)
                                .observaciones("Pago mensualidad marzo")
                                .build();

                PagoResponseDTO response = PagoResponseDTO.builder()
                                .idPago(100L)
                                .montoPagado(new BigDecimal("150.00"))
                                .build();

                when(pagoService.registrarPago(any(PagoRequestDTO.class), any(Usuario.class))).thenReturn(response);

                mockMvc.perform(post("/api/finanzas/pagos")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isOk());
        }

        @Test
        @WithMockUser(username = "secretaria@gmail.com", roles = "SECRETARIA")
        void registrarPago_DeberiaRetornar400_CuandoMontoEsInvalido() throws Exception {
                PagoRequestDTO request = PagoRequestDTO.builder()
                                .idCuentaCobrar(10L)
                                .montoPagado(new BigDecimal("-10.00")) // Inválido
                                .metodoPago(MetodoPago.EFECTIVO)
                                .build();

                mockMvc.perform(post("/api/finanzas/pagos")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                                .andExpect(status().isBadRequest());
        }
}
