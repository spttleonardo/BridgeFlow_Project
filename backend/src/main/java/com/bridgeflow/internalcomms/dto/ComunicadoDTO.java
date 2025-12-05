package com.bridgeflow.internalcomms.dto;

import com.bridgeflow.internalcomms.entity.Comunicado;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
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
        @NotBlank(message = "Título é obrigatório")
        @Size(max = 255, message = "Título muito longo")
        private String titulo;
        @NotBlank(message = "Conteúdo é obrigatório")
        private String conteudo;
        @NotNull(message = "Prioridade é obrigatória")
        private Comunicado.Prioridade prioridade = Comunicado.Prioridade.MEDIA;
        private Long secretariaDestinoId;
        private String emailNotificacao;
    }

    @Data
    public static class UpdateStatus {
        private Comunicado.StatusComunicado status;
    }

    @Data
    public static class Filtros {
        private Long secretariaOrigemId;
        private Long secretariaDestinoId;
        private Comunicado.StatusComunicado status;
        private Comunicado.Prioridade prioridade;
    }
}
