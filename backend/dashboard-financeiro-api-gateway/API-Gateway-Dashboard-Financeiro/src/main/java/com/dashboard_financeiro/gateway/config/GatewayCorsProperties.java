package com.dashboard_financeiro.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import java.util.List;

@Validated
@ConfigurationProperties(prefix = "gateway.cors")
public record GatewayCorsProperties(
        List<String> allowedOrigins,
        List<String> allowedMethods
) {

    public List<String> resolvedOrigins() {
        return allowedOrigins == null ? List.of("*") : allowedOrigins;
    }

    public List<String> resolvedMethods() {
        return allowedMethods == null ? List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS") : allowedMethods;
    }
}
