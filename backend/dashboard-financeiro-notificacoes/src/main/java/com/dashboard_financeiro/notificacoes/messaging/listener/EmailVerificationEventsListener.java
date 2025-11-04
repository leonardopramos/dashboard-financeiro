package com.dashboard_financeiro.notificacoes.messaging.listener;

import com.dashboard_financeiro.notificacoes.application.EmailNotificationService;
import com.dashboard_financeiro.notificacoes.application.NotificationUserService;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import com.dashboard_financeiro.notificacoes.messaging.event.EmailVerificationRequestedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class EmailVerificationEventsListener {

    private final NotificationUserService userService;
    private final EmailNotificationService emailNotificationService;

    @KafkaListener(
            topics = "${messaging.topics.email-verification-events}",
            properties = "spring.json.value.default.type=com.dashboard_financeiro.notificacoes.messaging.event.EmailVerificationRequestedEvent"
    )
    public void handle(EmailVerificationRequestedEvent event) {
        log.debug("Recebida solicitação de verificação para usuário {}", event.userId());
        NotificationUserEntity user = userService.findById(event.userId());
        emailNotificationService.sendEmailVerification(event, user);
    }
}
