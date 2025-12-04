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

    public static class Create {
        private String titulo;
        private String descricao;
        private Long responsavelId;
        private LocalDateTime prazo;

        // Getters e Setters
        public String getTitulo() {
            return titulo;
        }

        public void setTitulo(String titulo) {
            this.titulo = titulo;
        }

        public String getDescricao() {
            return descricao;
        }

        public void setDescricao(String descricao) {
            this.descricao = descricao;
        }

        public Long getResponsavelId() {
            return responsavelId;
        }

        public void setResponsavelId(Long responsavelId) {
            this.responsavelId = responsavelId;
        }

        public LocalDateTime getPrazo() {
            return prazo;
        }

        public void setPrazo(LocalDateTime prazo) {
            this.prazo = prazo;
        }
    }

    public static class Filtros {
        private Decisao.StatusDecisao status;
        private Long responsavelId;

        // Construtores
        public Filtros() {}

        public Filtros(Decisao.StatusDecisao status, Long responsavelId) {
            this.status = status;
            this.responsavelId = responsavelId;
        }

        // Getters e Setters
        public Decisao.StatusDecisao getStatus() {
            return status;
        }

        public void setStatus(Decisao.StatusDecisao status) {
            this.status = status;
        }

        public Long getResponsavelId() {
            return responsavelId;
        }

        public void setResponsavelId(Long responsavelId) {
            this.responsavelId = responsavelId;
        }
    }
}
