package com.bridgeflow.internalcomms.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ComentarioDTO {

    private Long id;
    private String conteudo;
    private Long decisaoId;
    private Long usuarioId;
    private String usuarioNome;
    private LocalDateTime dataCriacao;

    @Data
    public static class Create {
        private String conteudo;
    }
}
