package com.dashboard_financeiro.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import java.util.List;

@Validated
@ConfigurationProperties(prefix = "gateway.security")
public record GatewaySecurityProperties(
        List<String> publicPaths
) {

    public List<String> resolvedPublicPaths() {
        return publicPaths == null ? List.of() : publicPaths;
    }
}
