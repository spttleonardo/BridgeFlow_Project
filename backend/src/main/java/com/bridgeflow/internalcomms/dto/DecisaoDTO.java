package com.bridgeflow.internalcomms.dto;

import com.bridgeflow.internalcomms.entity.Decisao;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
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
        @NotBlank(message = "Título é obrigatório")
        @Size(max = 255, message = "Título muito longo")
        private String titulo;
        @NotBlank(message = "Descrição é obrigatória")
        private String descricao;
        @NotNull(message = "Responsável é obrigatório")
        private Long responsavelId;
        @FutureOrPresent(message = "Prazo deve ser uma data futura")
        private LocalDateTime prazo;
        @Email(message = "E-mail inválido")
        private String emailNotificacao;
    }

    @Data
    public static class Filtros {
        private Decisao.StatusDecisao status;
        private Long responsavelId;
    }
}
