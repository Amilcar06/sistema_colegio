package com.unidadeducativa.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.unidadeducativa.BaseIntegrationTest;
import com.unidadeducativa.auth.dto.LoginRequest;
import com.unidadeducativa.auth.dto.RegistroInstitucionRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class AuthControllerTest extends BaseIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    public void shouldRegisterSchoolSuccessfully() throws Exception {
        String uniqueId = java.util.UUID.randomUUID().toString().substring(0, 8);
        RegistroInstitucionRequest request = new RegistroInstitucionRequest();
        request.setNombreInstitucion("Test School " + uniqueId);
        request.setSie("1234" + uniqueId);
        request.setDireccion("Test Address " + uniqueId);
        request.setNombreDirector("Test");
        request.setApellidoDirector("Director");
        request.setCiDirector("77" + uniqueId);
        request.setCorreoDirector("director-" + uniqueId + "@gmail.com");
        request.setPasswordDirector("123456");

        mockMvc.perform(post("/api/auth/register-school")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andDo(org.springframework.test.web.servlet.result.MockMvcResultHandlers.print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists());
    }

    @Test
    public void shouldLoginSuccessfullyWithValidCredentials() throws Exception {
        // Register first to ensure user exists
        String uniqueId = java.util.UUID.randomUUID().toString().substring(0, 8);
        RegistroInstitucionRequest request = new RegistroInstitucionRequest();
        request.setNombreInstitucion("Test School " + uniqueId);
        request.setSie("8765" + uniqueId);
        request.setDireccion("Test Address " + uniqueId);
        request.setNombreDirector("Test");
        request.setApellidoDirector("Director" + uniqueId);
        request.setCiDirector("88" + uniqueId);
        request.setCorreoDirector("director-" + uniqueId + "@gmail.com");
        request.setPasswordDirector("123456");

        mockMvc.perform(post("/api/auth/register-school")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        // Now Login
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setCorreo("director-" + uniqueId + "@gmail.com");
        loginRequest.setPassword("123456");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists());
    }

    @Test
    public void shouldFailLoginWithInvalidCredentials() throws Exception {
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setCorreo("nonexistent@gmail.com");
        loginRequest.setPassword("wrongpass");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized());
    }
}
