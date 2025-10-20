package com.dashboard_financeiro.cadastroautenticacao.application;

import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.UserJpaRepository;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.AuthResponse;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.LoginRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.RefreshTokenRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserJpaRepository userJpaRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthResponse login(LoginRequest request) {
        String normalizedEmail = normalizeEmail(request.email());

        UserJpaEntity user = userJpaRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("Credenciais inválidas"));

        if (!user.isActive()) {
            throw new IllegalArgumentException("Usuário desativado. Contate o suporte.");
        }

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new IllegalArgumentException("Credenciais inválidas");
        }

        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        return AuthResponse.of(accessToken, refreshToken, UserDTO.from(user));
    }

    public AuthResponse refresh(RefreshTokenRequest request) {
        String rawToken = request.refreshToken().trim();
        if (!StringUtils.hasText(rawToken)) {
            throw new IllegalArgumentException("Refresh token não informado");
        }

        if (!jwtService.isRefreshToken(rawToken)) {
            throw new IllegalArgumentException("Refresh token inválido");
        }

        UUID userId = jwtService.extractUserId(rawToken);
        UserJpaEntity user = userJpaRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        if (!user.isActive()) {
            throw new IllegalArgumentException("Usuário desativado. Contate o suporte.");
        }

        if (jwtService.isTokenExpired(rawToken)) {
            throw new IllegalArgumentException("Refresh token expirado");
        }

        String newAccess = jwtService.generateAccessToken(user);
        return AuthResponse.of(newAccess, rawToken, UserDTO.from(user));
    }

    public void logout(String refreshToken) {
        log.info("Logout solicitado. Token recebido: {}", refreshToken != null ? "***" : "vazio");
        // Stateless: nenhuma ação adicional necessária.
    }

    @Transactional(readOnly = true)
    public UserDTO getCurrentUser(String token) {
        UUID userId = jwtService.extractUserId(token);
        UserJpaEntity user = userJpaRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        if (!user.isActive()) {
            throw new IllegalArgumentException("Usuário desativado. Contate o suporte.");
        }

        return UserDTO.from(user);
    }

    private String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase();
    }
}
