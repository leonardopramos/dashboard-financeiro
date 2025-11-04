package com.dashboard_financeiro.notificacoes.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "messaging.topics")
public record NotificationTopicsProperties(
        String userEvents,
        String transactionEvents,
        String goalEvents,
        String emailVerificationEvents
) {
}
