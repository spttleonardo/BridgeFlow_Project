package com.bridgeflow.internalcomms.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UsuarioResumoDTO {
    private Long id;
    private String nome;
    private String email;
    private String cargo;
    private String secretariaNome;
}
