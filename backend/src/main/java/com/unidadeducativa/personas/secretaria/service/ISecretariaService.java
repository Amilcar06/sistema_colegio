package com.unidadeducativa.personas.secretaria.service;

import com.unidadeducativa.personas.secretaria.dto.SecretariaRequestDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaUpdateDTO;
import com.unidadeducativa.personas.secretaria.dto.SecretariaResponseDTO;

import java.util.List;

public interface ISecretariaService {
    List<SecretariaResponseDTO> listarSecretarias();

    SecretariaResponseDTO obtenerPorId(Long id);

    SecretariaResponseDTO obtenerPorCorreo(String correo);

    SecretariaResponseDTO registrarSecretaria(SecretariaRequestDTO dto);

    SecretariaResponseDTO actualizarSecretaria(Long id, SecretariaUpdateDTO dto);

    SecretariaResponseDTO actualizarPorCorreo(String correo, SecretariaUpdateDTO dto);

    void eliminarSecretaria(Long id);

    void cambiarEstadoSecretaria(Long id, boolean estado);
}
