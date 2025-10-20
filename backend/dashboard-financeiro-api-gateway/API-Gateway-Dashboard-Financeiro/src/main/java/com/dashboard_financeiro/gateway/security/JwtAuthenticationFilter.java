package com.dashboard_financeiro.gateway.security;

import com.dashboard_financeiro.gateway.config.GatewaySecurityProperties;
import jakarta.annotation.PostConstruct;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.util.pattern.PathPattern;
import org.springframework.web.util.pattern.PathPatternParser;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    private final JwtTokenProvider tokenProvider;
    private final GatewaySecurityProperties securityProperties;
    private final PathPatternParser pathParser = new PathPatternParser();
    private List<PathPattern> publicPatterns = List.of();

    @PostConstruct
    void init() {
        this.publicPatterns = securityProperties.resolvedPublicPaths().stream()
                .map(pathParser::parse)
                .collect(Collectors.toList());
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();

        if (shouldBypass(request)) {
            return chain.filter(exchange);
        }

        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith("Bearer ")) {
            return unauthorized(exchange, "Token ausente ou inválido");
        }

        String token = authHeader.substring(7);

        JwtPayload payload;
        try {
            payload = tokenProvider.parseAndValidate(token);
        } catch (Exception ex) {
            log.debug("Token inválido recebido em {}: {}", request.getPath(), ex.getMessage());
            return unauthorized(exchange, "Token inválido");
        }

        ServerHttpRequest.Builder mutatedRequest = request.mutate()
                .header("X-User-Id", payload.userId().toString())
                .header("X-User-Role", payload.role());

        if (payload.email() != null) {
            mutatedRequest.header("X-User-Email", payload.email());
        }

        if (payload.name() != null) {
            mutatedRequest.header("X-User-Name", payload.name());
        }

        exchange.getAttributes().put("authenticatedUser", payload);

        return chain.filter(exchange.mutate().request(mutatedRequest.build()).build());
    }

    @Override
    public int getOrder() {
        return -10;
    }

    private boolean shouldBypass(ServerHttpRequest request) {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod().toString())) {
            return true;
        }

        var path = request.getPath().pathWithinApplication();
        return publicPatterns.stream().anyMatch(pattern -> pattern.matches(path));
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange, String message) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);
        response.getHeaders().set(HttpHeaders.WWW_AUTHENTICATE, "Bearer");

        String body = String.format(
                "{\"timestamp\":\"%s\",\"status\":401,\"error\":\"Unauthorized\",\"message\":\"%s\",\"path\":\"%s\"}",
                Instant.now(),
                escapeJson(message),
                exchange.getRequest().getPath()
        );

        return response.writeWith(Mono.just(response.bufferFactory().wrap(body.getBytes(StandardCharsets.UTF_8))));
    }

    private String escapeJson(String message) {
        return message.replace("\"", "\\\"");
    }
}
