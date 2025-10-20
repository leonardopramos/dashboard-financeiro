package com.dashboard_financeiro.cadastroautenticacao.messaging;

import com.dashboard_financeiro.cadastroautenticacao.messaging.event.UserRegisteredEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.CompletableFuture;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserEventProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${messaging.topics.user-events:user.events}")
    private String userEventsTopic;

    public void publishUserRegistered(UserRegisteredEvent event) {
        CompletableFuture<?> future = kafkaTemplate.send(userEventsTopic, event.userId().toString(), event);
        future.whenComplete((result, ex) -> {
            if (ex != null) {
                log.error("Falha ao publicar evento de usuário ({}): {}", event.userId(), ex.getMessage(), ex);
            } else {
                log.info("Evento de usuário publicado no tópico {} para {}", userEventsTopic, event.userId());
            }
        });
    }
}
