package com.bridgeflow.internalcomms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.List;

@Data
public class RegisterRequest {
    @NotBlank(message = "Nome é obrigatório")
    private String name;

    @NotBlank(message = "Email é obrigatório")
    private String email;

    @NotBlank(message = "Senha é obrigatória")
    private String password;

    private List<String> roles;

    // Optional fields
    @NotNull(message = "Secretaria é obrigatória")
    private Long secretariaId;
    private String departamento;
    @NotBlank(message = "Cargo é obrigatório")
    private String cargo;
}
