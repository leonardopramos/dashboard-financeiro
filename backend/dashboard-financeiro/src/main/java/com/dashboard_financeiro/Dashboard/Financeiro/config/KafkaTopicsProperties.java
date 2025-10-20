package com.dashboard_financeiro.Dashboard.Financeiro.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "messaging.topics")
public record KafkaTopicsProperties(
        String transactionEvents,
        String goalEvents
) {
}
