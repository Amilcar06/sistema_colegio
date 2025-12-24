package com.unidadeducativa.academia;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.unidadeducativa.BaseIntegrationTest;
import com.unidadeducativa.academia.inscripcion.dto.InscripcionRequestDTO;
import com.unidadeducativa.academia.inscripcion.dto.InscripcionResponseDTO;
import com.unidadeducativa.academia.inscripcion.service.IInscripcionService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class InscripcionControllerTest extends BaseIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private IInscripcionService inscripcionService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "SECRETARIA")
    void registrarInscripcion_DeberiaRetornar200_CuandoDatosValidos() throws Exception {
        InscripcionRequestDTO request = new InscripcionRequestDTO();
        request.setIdEstudiante(1L);
        request.setIdCurso(5L);

        InscripcionResponseDTO response = new InscripcionResponseDTO();
        // Set properties if needed for response verification, skipping for status check

        when(inscripcionService.registrar(any(InscripcionRequestDTO.class))).thenReturn(response);

        mockMvc.perform(post("/api/inscripciones")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(roles = "SECRETARIA")
    void registrarInscripcion_DeberiaRetornar400_CuandoFaltanCampos() throws Exception {
        InscripcionRequestDTO request = new InscripcionRequestDTO();
        // Missing fields

        mockMvc.perform(post("/api/inscripciones")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }
}
