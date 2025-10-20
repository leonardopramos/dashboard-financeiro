package com.dashboard_financeiro.notificacoes.messaging.event;

import java.time.Instant;
import java.util.UUID;

public record UserCreatedEvent(
        UUID userId,
        String email,
        String name,
        String role,
        boolean emailVerified,
        Instant registeredAt
) {
}
