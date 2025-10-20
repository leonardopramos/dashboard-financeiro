package com.dashboard_financeiro.cadastroautenticacao.security;

import com.dashboard_financeiro.cadastroautenticacao.application.JwtService;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.UserJpaRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final List<String> PUBLIC_ENDPOINTS = List.of(
            "/api/v1/auth/**",
            "/api/v1/users"
    );

    private final JwtService jwtService;
    private final UserJpaRepository userJpaRepository;
    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (!StringUtils.hasText(header) || !header.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = header.substring(7);

        try {
            if (jwtService.isTokenExpired(token)) {
                log.debug("Token expirado recebido em {}", request.getRequestURI());
                filterChain.doFilter(request, response);
                return;
            }

            if (SecurityContextHolder.getContext().getAuthentication() != null) {
                filterChain.doFilter(request, response);
                return;
            }

            UUID userId = jwtService.extractUserId(token);
            UserJpaEntity user = userJpaRepository.findById(userId).orElse(null);
            if (user == null || !user.isActive()) {
                filterChain.doFilter(request, response);
                return;
            }

            AuthenticatedUser principal = AuthenticatedUser.from(user);
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    principal,
                    null,
                    principal.getAuthorities()
            );
            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authentication);
        } catch (Exception ex) {
            log.debug("Falha ao processar token JWT em {}: {}", request.getRequestURI(), ex.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String path = request.getRequestURI();
        return PUBLIC_ENDPOINTS.stream().anyMatch(pattern -> pathMatcher.match(pattern, path))
                && !"GET".equalsIgnoreCase(request.getMethod());
    }
}
