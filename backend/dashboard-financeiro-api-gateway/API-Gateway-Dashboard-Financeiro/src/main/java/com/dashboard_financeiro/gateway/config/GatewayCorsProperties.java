package com.dashboard_financeiro.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import java.util.Arrays;
import java.util.List;

@Validated
@ConfigurationProperties(prefix = "gateway.cors")
public record GatewayCorsProperties(
        List<String> allowedOrigins,
        List<String> allowedMethods
) {

    public List<String> resolvedOrigins() {
        return normalize(allowedOrigins, List.of("*"));
    }

    public List<String> resolvedMethods() {
        return normalize(allowedMethods, List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
    }

    private List<String> normalize(List<String> values, List<String> defaultValue) {
        if (values == null || values.isEmpty()) {
            return defaultValue;
        }

        if (values.size() == 1) {
            String single = values.getFirst();
            if (single != null && single.contains(",")) {
                return Arrays.stream(single.split(","))
                        .map(String::trim)
                        .filter(s -> !s.isEmpty())
                        .toList();
            }
        }

        return values;
    }
}
