package com.unidadeducativa.usuario.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;
import java.time.LocalDate;

@Data
public class UsuarioUpdateDTO {
    private String nombres;
    private String apellidoPaterno;
    private String apellidoMaterno;
    @Size(min = 5, max = 50)
    private String ci;
    private String fotoPerfil;
    private Boolean estado;
    private LocalDate fechaNacimiento;
}
