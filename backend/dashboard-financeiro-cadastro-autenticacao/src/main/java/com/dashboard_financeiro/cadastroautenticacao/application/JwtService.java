package com.dashboard_financeiro.cadastroautenticacao.application;

import com.dashboard_financeiro.cadastroautenticacao.config.JwtProperties;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.DecodingException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

@Slf4j
@Service
@RequiredArgsConstructor
public class JwtService {

    private final JwtProperties properties;
    private final AtomicReference<Key> cachedKey = new AtomicReference<>();

    public String generateAccessToken(UserJpaEntity user) {
        return generateToken(user, Duration.ofMinutes(properties.accessTokenMinutes()), Map.of(
                "email", user.getEmail(),
                "name", user.getName(),
                "role", safeRole(user)
        ));
    }

    public String generateRefreshToken(UserJpaEntity user) {
        return generateToken(user, Duration.ofMinutes(properties.refreshTokenMinutes()), Map.of(
                "email", user.getEmail(),
                "type", "refresh"
        ));
    }

    public String generateToken(UserJpaEntity user, Duration validity, Map<String, Object> extraClaims) {
        Instant issuedAt = Instant.now();
        Instant expiresAt = issuedAt.plus(validity);

        return Jwts.builder()
                .setClaims(extraClaims)
                .setSubject(user.getId().toString())
                .setIssuer(properties.issuer())
                .setIssuedAt(Date.from(issuedAt))
                .setExpiration(Date.from(expiresAt))
                .signWith(resolveSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    private String safeRole(UserJpaEntity user) {
        return user.getRole() != null ? user.getRole() : "USER";
    }

    public Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(resolveSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public UUID extractUserId(String token) {
        return UUID.fromString(extractAllClaims(token).getSubject());
    }

    public String extractEmail(String token) {
        return extractAllClaims(token).get("email", String.class);
    }

    public boolean isTokenExpired(String token) {
        Date expiration = extractAllClaims(token).getExpiration();
        return expiration.before(new Date());
    }

    public boolean isRefreshToken(String token) {
        return "refresh".equals(extractAllClaims(token).get("type", String.class));
    }

    public boolean isValid(String token, UUID expectedUserId) {
        try {
            Claims claims = extractAllClaims(token);
            return !isTokenExpired(token) && UUID.fromString(claims.getSubject()).equals(expectedUserId);
        } catch (Exception ex) {
            log.debug("Token JWT inválido: {}", ex.getMessage());
            return false;
        }
    }

    private Key resolveSigningKey() {
        Key key = cachedKey.get();
        if (key != null) {
            return key;
        }

        byte[] keyBytes;
        try {
            keyBytes = Decoders.BASE64.decode(properties.secret());
        } catch (IllegalArgumentException | DecodingException ex) {
            log.warn("Chave JWT não está em Base64; usando UTF-8 direta.");
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
