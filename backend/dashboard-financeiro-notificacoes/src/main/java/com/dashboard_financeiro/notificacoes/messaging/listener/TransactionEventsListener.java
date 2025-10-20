package com.dashboard_financeiro.notificacoes.messaging.listener;

import com.dashboard_financeiro.notificacoes.application.EmailNotificationService;
import com.dashboard_financeiro.notificacoes.application.NotificationUserService;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import com.dashboard_financeiro.notificacoes.messaging.event.TransactionCreatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class TransactionEventsListener {

    private final NotificationUserService userService;
    private final EmailNotificationService emailNotificationService;

    @KafkaListener(
            topics = "${messaging.topics.transaction-events}",
            properties = "spring.json.value.default.type=com.dashboard_financeiro.notificacoes.messaging.event.TransactionCreatedEvent"
    )
    public void handle(TransactionCreatedEvent event) {
        NotificationUserEntity user = userService.findById(event.userId());
        if (user == null) {
            log.warn("Usuário {} não encontrado na base de notificações. Utilizando e-mail de fallback.", event.userId());
        }
        log.debug("Processando evento de transação {} para usuário {}", event.transactionId(), event.userId());
        emailNotificationService.sendTransactionNotification(event, user);
    }
}
