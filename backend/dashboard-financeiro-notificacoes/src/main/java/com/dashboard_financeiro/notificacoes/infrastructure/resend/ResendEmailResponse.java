package com.dashboard_financeiro.notificacoes.infrastructure.resend;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.OffsetDateTime;
import java.util.List;

public record ResendEmailResponse(
        String id,
        String from,
        List<String> to,
        @JsonProperty("created_at") OffsetDateTime createdAt
) {
}
