package com.bridgeflow.internalcomms.dto;

import com.bridgeflow.internalcomms.entity.Decisao;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DecisaoDTO {

    private Long id;
    private String titulo;
    private String descricao;
    private Decisao.StatusDecisao status;
    private Long responsavelId;
    private String responsavelNome;
    private Long usuarioCriadorId;
    private String usuarioCriadorNome;
    private LocalDateTime prazo;
    private LocalDateTime dataConclusao;
    private LocalDateTime dataCriacao;

    @Data
    public static class Create {
        private String titulo;
        private String descricao;
        private Long responsavelId;
        private LocalDateTime prazo;
    }

    @Data
    public static class Filtros {
        private Decisao.StatusDecisao status;
        private Long responsavelId;
    }
}
