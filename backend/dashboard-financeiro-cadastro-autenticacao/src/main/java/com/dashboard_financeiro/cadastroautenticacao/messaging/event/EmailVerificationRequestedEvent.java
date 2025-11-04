package com.dashboard_financeiro.cadastroautenticacao.messaging.event;

import java.time.Instant;
import java.util.UUID;

public record EmailVerificationRequestedEvent(
        UUID userId,
        String email,
        String name,
        String code,
        Instant expiresAt,
        String reason
) {
}
