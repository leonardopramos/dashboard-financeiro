package com.dashboard_financeiro.notificacoes.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;
import jakarta.validation.constraints.NotBlank;


@Validated
@ConfigurationProperties(prefix = "notifications.email")
public record NotificationEmailProperties(
        @NotBlank String from,
        boolean enabled,
        String fallback,
        String dashboardUrl
) {
    public NotificationEmailProperties {
        if (fallback == null || fallback.isBlank()) {
            fallback = from;
        }
        if (dashboardUrl == null || dashboardUrl.isBlank()) {
            dashboardUrl = "https://app.dashboard-financeiro.local";
        }
    }
}
