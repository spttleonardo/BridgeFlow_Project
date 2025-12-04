package com.bridgeflow.internalcomms.service;

import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class MqService {

    private final RabbitTemplate rabbitTemplate;

    @Value("${app.mq.exchange}")
    private String exchange;

    @Value("${app.mq.routing-key}")
    private String routingKey;

    public MqService(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void notificar(Map<String, Object> payload) {
        rabbitTemplate.convertAndSend(exchange, routingKey, payload);
    }
}

