package com.dashboard_financeiro.Dashboard.Financeiro.security;

import com.dashboard_financeiro.Dashboard.Financeiro.config.JwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

@Component
@RequiredArgsConstructor
public class JwtTokenProvider {

    private final JwtProperties properties;
    private final AtomicReference<Key> cachedKey = new AtomicReference<>();

    public AuthenticatedUser parse(String token) {
        Claims claims = parseClaims(token);
        Instant expiration = claims.getExpiration().toInstant();
        if (expiration.isBefore(Instant.now())) {
            throw new IllegalArgumentException("Token expirado");
        }

        UUID userId = UUID.fromString(claims.getSubject());
        String email = claims.get("email", String.class);
        String name = claims.get("name", String.class);
        String role = Optional.ofNullable(claims.get("role", String.class)).orElse("USER");

        return new AuthenticatedUser(userId, email, name, role);
    }

    private Claims parseClaims(String token) {
        return Jwts.parserBuilder()
                .requireIssuer(properties.issuer())
                .setSigningKey(resolveSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Key resolveSigningKey() {
        Key key = cachedKey.get();
        if (key != null) {
            return key;
        }

        byte[] keyBytes;
        try {
            keyBytes = Decoders.BASE64.decode(properties.secret());
        } catch (IllegalArgumentException ex) {
            keyBytes = properties.secret().getBytes(StandardCharsets.UTF_8);
        }

        if (keyBytes.length < 32) {
            throw new IllegalStateException("security.jwt.secret deve possuir ao menos 32 bytes");
        }

        Key signingKey = Keys.hmacShaKeyFor(keyBytes);
        cachedKey.compareAndSet(null, signingKey);
        return signingKey;
    }
}
