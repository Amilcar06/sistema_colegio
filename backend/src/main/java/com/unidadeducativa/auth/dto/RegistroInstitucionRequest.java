package com.unidadeducativa.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegistroInstitucionRequest {

    // Datos Institución
    @NotBlank(message = "El nombre de la institución es obligatorio")
    private String nombreInstitucion;

    @NotBlank(message = "El SIE es obligatorio")
    private String sie;

    private String direccion;
    private String logoUrl;

    // Datos Director (Usuario Admin de la UE)
    @NotBlank(message = "El nombre del director es obligatorio")
    private String nombreDirector;

    @NotBlank(message = "El apellido del director es obligatorio")
    private String apellidoDirector;

    @NotBlank(message = "El CI del director es obligatorio")
    private String ciDirector;

    @NotBlank(message = "El correo es obligatorio")
    @Email(message = "Formato de correo inválido")
    private String correoDirector;

    @NotBlank(message = "La contraseña es obligatoria")
    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
    private String passwordDirector;
}
