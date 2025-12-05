package com.bridgeflow.internalcomms.service;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class MqService {

    private static final Logger logger = LoggerFactory.getLogger(MqService.class);
    private final RabbitTemplate rabbitTemplate;

    @Value("${app.mq.exchange:bridgeflow.exchange}")
    private String exchange;

    @Value("${app.mq.routing-key:bridgeflow.routingkey}")
    private String routingKey;

    public MqService(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void notificar(Map<String, Object> payload) {
        try {
            rabbitTemplate.convertAndSend(exchange, routingKey, payload);
            logger.info("Mensagem enviada para o RabbitMQ: exchange={}, routingKey={}, payload={}", exchange, routingKey, payload);
        } catch (Exception e) {
            logger.error("Erro ao enviar mensagem para o RabbitMQ", e);
            // Aqui você pode lançar a exceção novamente ou tratar conforme a necessidade do seu domínio
        }
    }

    public void sendVerificationEmail(String email, String codigo) {
        notificar(Map.of(
                "type", "email.verificacao",
                "usuarioEmail", email,
                "codigo", codigo,
                "expiresAt", "PT30M"
        ));
    }
}

