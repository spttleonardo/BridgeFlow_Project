package com.bridgeflow.internalcomms.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponse {

    private String token;
    private String tipo = "Bearer";
    private Long expiresIn;
    private UsuarioDTO usuario;

    @Data
    @AllArgsConstructor
    public static class UsuarioDTO {
        private Long id;
        private String nome;
        private String email;
        private String secretariaNome;
        private String cargo;
    }
}
