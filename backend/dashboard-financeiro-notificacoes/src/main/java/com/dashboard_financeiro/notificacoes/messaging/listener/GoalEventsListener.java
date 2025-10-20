package com.dashboard_financeiro.notificacoes.messaging.listener;

import com.dashboard_financeiro.notificacoes.application.EmailNotificationService;
import com.dashboard_financeiro.notificacoes.application.NotificationUserService;
import com.dashboard_financeiro.notificacoes.infrastructure.persistence.entity.NotificationUserEntity;
import com.dashboard_financeiro.notificacoes.messaging.event.GoalStatusChangedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class GoalEventsListener {

    private final NotificationUserService userService;
    private final EmailNotificationService emailNotificationService;

    @KafkaListener(
            topics = "${messaging.topics.goal-events}",
            properties = "spring.json.value.default.type=com.dashboard_financeiro.notificacoes.messaging.event.GoalStatusChangedEvent"
    )
    public void handle(GoalStatusChangedEvent event) {
        NotificationUserEntity user = userService.findById(event.userId());
        if (user == null) {
            log.warn("Usuário {} não encontrado na base de notificações. Utilizando e-mail de fallback.", event.userId());
        }
        if (!"ACHIEVED".equalsIgnoreCase(event.status()) && !"EXCEEDED".equalsIgnoreCase(event.status())) {
            log.debug("Evento de meta {} ignorado (status={})", event.goalId(), event.status());
            return;
        }
        log.debug("Processando evento de meta {} para usuário {}", event.goalId(), event.userId());
        emailNotificationService.sendGoalNotification(event, user);
    }
}
