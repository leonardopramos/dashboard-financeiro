package com.dashboard_financeiro.cadastroautenticacao.messaging.event;

import java.time.Instant;
import java.util.UUID;

public record UserRegisteredEvent(
        UUID userId,
        String email,
        String name,
        String role,
        boolean emailVerified,
        Instant registeredAt
) {
}
