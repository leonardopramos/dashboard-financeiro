package com.dashboard_financeiro.cadastroautenticacao.messaging;

import com.dashboard_financeiro.cadastroautenticacao.messaging.event.EmailVerificationRequestedEvent;
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

    @Value("${messaging.topics.email-verification-events:user.verification}")
    private String verificationEventsTopic;

    public void publishUserRegistered(UserRegisteredEvent event) {
        sendEvent(userEventsTopic, event.userId().toString(), event, "usuário registrado");
    }

    public void publishVerificationRequested(EmailVerificationRequestedEvent event) {
        sendEvent(verificationEventsTopic, event.userId().toString(), event, "verificação de e-mail");
    }

    private void sendEvent(String topic, String key, Object payload, String description) {
        CompletableFuture<?> future = kafkaTemplate.send(topic, key, payload);
        future.whenComplete((result, ex) -> {
            if (ex != null) {
                log.error("Falha ao publicar evento de {} ({}): {}", description, key, ex.getMessage(), ex);
            } else {
                log.info("Evento de {} publicado no tópico {} para {}", description, topic, key);
            }
        });
    }
}
