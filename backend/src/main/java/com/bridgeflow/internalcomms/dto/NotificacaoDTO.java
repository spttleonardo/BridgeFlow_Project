package com.bridgeflow.internalcomms.dto;

import com.bridgeflow.internalcomms.entity.Notificacao;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class NotificacaoDTO {

    private Long id;
    private String titulo;
    private String mensagem;
    private Notificacao.TipoNotificacao tipo;
    private Long usuarioDestinoId;
    private String usuarioDestinoNome;
    private Long usuarioOrigemId;
    private String usuarioOrigemNome;
    private Boolean lida;
    private LocalDateTime dataCriacao;

    @Data
    public static class Create {
        @NotBlank(message = "Título é obrigatório")
        @Size(max = 255, message = "Título muito longo")
        private String titulo;

        @NotBlank(message = "Mensagem é obrigatória")
        private String mensagem;

        @NotNull(message = "Tipo de notificação é obrigatório")
        private Notificacao.TipoNotificacao tipo = Notificacao.TipoNotificacao.SISTEMA;

        @NotNull(message = "Usuário destino é obrigatório")
        private Long usuarioDestinoId;

        @Email(message = "E-mail inválido")
        private String emailNotificacao;

        private Long decisaoId;
        private Long comunicadoId;
    }
}
