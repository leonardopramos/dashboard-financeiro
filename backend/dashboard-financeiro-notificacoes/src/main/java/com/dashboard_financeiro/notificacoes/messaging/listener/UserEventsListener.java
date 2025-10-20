package com.dashboard_financeiro.notificacoes.messaging.listener;

import com.dashboard_financeiro.notificacoes.application.NotificationUserService;
import com.dashboard_financeiro.notificacoes.messaging.event.UserCreatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserEventsListener {

    private final NotificationUserService userService;

    @KafkaListener(
            topics = "${messaging.topics.user-events}",
            properties = "spring.json.value.default.type=com.dashboard_financeiro.notificacoes.messaging.event.UserCreatedEvent"
    )
    public void handle(UserCreatedEvent event) {
        log.debug("Recebido evento de usuário {}", event.userId());
        userService.upsertUser(event.userId(), event.email(), event.name(), true);
    }
}
