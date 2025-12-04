package com.monitorellas.mq;

import com.monitorellas.mail.MailService;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class EmailListener {

    private final MailService mailService;

    @Value("${spring.application.name}")
    private String appName;

    public EmailListener(MailService mailService) {
        this.mailService = mailService;
    }

    @RabbitListener(queues = "${app.mq.queue}")
    public void onOperacaoCreated(@Payload Map<String, Object> payload) {
        String type = (String) payload.get("type");
        if (type == null) return;
        switch (type) {
            case "email.verificacao" -> handleEmailVerificacao(payload);
            case "comunicado.criado" -> handleComunicadoCriado(payload);
            case "decisao.criada"    -> handleDecisaoCriada(payload);
            default -> {
            }
        }
    }

    private void handleDecisaoCriada(Map<String, Object> payload) {
        String to = (String) payload.get("emailNotificacao");
        if (to == null || to.isBlank()) return;

        String decisaoTitulo = (String) payload.get("decisaoTitulo");
        String responsavelNome = (String) payload.get("responsavelNome");
        String prazo = (String) payload.get("prazo");

        String subject = "BridgeFlow - Nova Decisão Criada: " + decisaoTitulo;
        String body = String.format(
                "Olá,\n\nUma nova decisão foi criada no sistema BridgeFlow.\n\n" +
                        "Título: %s\n" +
                        "Responsável: %s\n" +
                        "Prazo: %s\n\n" +
                        "Acesse a plataforma para mais detalhes.\n\n" +
                        "Equipe BridgeFlow",
                decisaoTitulo, responsavelNome, prazo
        );
        mailService.send(to, subject, body);
    }

    private void handleComunicadoCriado(Map<String, Object> payload) {
        String to = (String) payload.get("emailNotificacao");
        if (to == null || to.isBlank()) return;

        String comunicadoTitulo = (String) payload.get("comunicadoTitulo");
        String remetente = (String) payload.get("remetente");
        String destinatario = (String) payload.get("destinatario");

        String subject = "BridgeFlow - Novo Comunicado: " + comunicadoTitulo;
        String body = String.format(
                "Olá,\n\nUm novo comunicado foi registrado no sistema BridgeFlow.\n\n" +
                        "Título: %s\n" +
                        "De: %s\n" +
                        "Para: %s\n\n" +
                        "Acesse a plataforma para mais detalhes.\n\n" +
                        "Equipe BridgeFlow",
                comunicadoTitulo, remetente, destinatario
        );
        mailService.send(to, subject, body);
    }

    private void handleEmailVerificacao(Map<String, Object> payload) {
        String to = (String) payload.get("usuarioEmail");
        if (to == null || to.isBlank()) return;
        String codigo = (String) payload.get("codigo");
        String expiresAt = (String) payload.get("expiresAt");
        String subject = "BridgeFlow - Verificação de e-mail";
        String body = "Olá,\n\n" +
                "Recebemos seu cadastro. Para ativar sua conta, utilize o código abaixo:\n\n" +
                "Código: " + codigo + "\n\n" +
                "Este código expira em: " + expiresAt + " (30 minutos).\n" +
                "Se você não solicitou este cadastro, ignore este e-mail.\n\n" +
                "Equipe BridgeFlow" + "\n";
        mailService.send(to, subject, body);
    }
}
