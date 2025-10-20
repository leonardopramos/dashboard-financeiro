package com.dashboard_financeiro.gateway.security;

import java.time.Instant;
import java.util.UUID;

public record JwtPayload(
        UUID userId,
        String email,
        String name,
        String role,
        Instant expiresAt
) {
}
