package com.bridgeflow.internalcomms.dto;

import com.bridgeflow.internalcomms.entity.Comunicado;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ComunicadoDTO {

    private Long id;
    private String titulo;
    private String conteudo;
    private Comunicado.Prioridade prioridade;
    private Comunicado.StatusComunicado status;
    private Long secretariaOrigemId;
    private String secretariaOrigemNome;
    private Long secretariaDestinoId;
    private String secretariaDestinoNome;
    private Long usuarioCriadorId;
    private String usuarioCriadorNome;
    private LocalDateTime dataCriacao;
    private LocalDateTime dataLeitura;

    @Data
    public static class Create {
        private String titulo;
        private String conteudo;
        private Comunicado.Prioridade prioridade = Comunicado.Prioridade.MEDIA;
        private Long secretariaDestinoId;
    }

    @Data
    public static class UpdateStatus {
        private Comunicado.StatusComunicado status;
    }

    public static class Filtros {
        private Long secretariaOrigemId;
        private Long secretariaDestinoId;
        private Comunicado.StatusComunicado status;
        private Comunicado.Prioridade prioridade;

        // Getters e Setters
        public Long getSecretariaOrigemId() {
            return secretariaOrigemId;
        }

        public void setSecretariaOrigemId(Long secretariaOrigemId) {
            this.secretariaOrigemId = secretariaOrigemId;
        }

        public Long getSecretariaDestinoId() {
            return secretariaDestinoId;
        }

        public void setSecretariaDestinoId(Long secretariaDestinoId) {
            this.secretariaDestinoId = secretariaDestinoId;
        }

        public Comunicado.StatusComunicado getStatus() {
            return status;
        }

        public void setStatus(Comunicado.StatusComunicado status) {
            this.status = status;
        }

        public Comunicado.Prioridade getPrioridade() {
            return prioridade;
        }

        public void setPrioridade(Comunicado.Prioridade prioridade) {
            this.prioridade = prioridade;
        }
    }
}
