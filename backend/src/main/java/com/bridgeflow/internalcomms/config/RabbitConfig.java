package com.bridgeflow.internalcomms.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitConfig {
    @Bean
    public DirectExchange bridgeflowExchange() {
        return new DirectExchange("bridgeflow.exchange", true, false);
    }

    @Bean
    public Queue emailOutboxQueue() {
        return new Queue("email.outbox", true);
    }

    @Bean
    public Binding emailOutboxBinding(Queue emailOutboxQueue, DirectExchange bridgeflowExchange) {
        return BindingBuilder.bind(emailOutboxQueue).to(bridgeflowExchange).with("bridgeflow.routingkey");
    }

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        final RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(jsonMessageConverter());
        return rabbitTemplate;
    }
}
