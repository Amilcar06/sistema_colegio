package com.unidadeducativa.finanzas;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.unidadeducativa.BaseIntegrationTest;
import com.unidadeducativa.auth.dto.LoginRequest;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class PagoControllerTest extends BaseIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String token;

    @BeforeEach
    public void setup() throws Exception {
        // Authenticate as Admin or Secretary to perform payments
        // Using the "admin@gmail.com" from seeder or creating one
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setCorreo("director@gmail.com"); // Exists from DataInitializer
        loginRequest.setPassword("123456");

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andReturn();

        String response = result.getResponse().getContentAsString();
        Map map = objectMapper.readValue(response, Map.class);
        this.token = (String) map.get("token");
    }

    @Test
    public void shouldListPagos() throws Exception {
        mockMvc.perform(get("/api/finanzas/pagos")
                .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());
    }
}
