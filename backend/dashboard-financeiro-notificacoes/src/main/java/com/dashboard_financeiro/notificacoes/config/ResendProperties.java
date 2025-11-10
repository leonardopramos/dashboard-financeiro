package com.dashboard_financeiro.notificacoes.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "notifications.email.resend")
public record ResendProperties(
        String apiKey,
        String baseUrl
) {

    public ResendProperties {
        if (baseUrl == null || baseUrl.isBlank()) {
            baseUrl = "https://api.resend.com";
        }
    }

    public boolean hasApiKey() {
        return apiKey != null && !apiKey.isBlank();
    }
}
