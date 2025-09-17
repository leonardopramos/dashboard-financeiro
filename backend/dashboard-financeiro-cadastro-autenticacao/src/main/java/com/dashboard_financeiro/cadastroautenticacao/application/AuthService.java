package com.dashboard_financeiro.cadastroautenticacao.application;

import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.UserJpaRepository;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.AuthResponse;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.LoginRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.RefreshTokenRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserJpaRepository userJpaRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthResponse login(LoginRequest request) {
        UserJpaEntity userJpaEntity = userJpaRepository.findByEmail(request.email())
                .orElseThrow(() -> new IllegalArgumentException("Credenciais inválidas"));

        if (!passwordEncoder.matches(request.password(), userJpaEntity.getPassword())) {
            throw new IllegalArgumentException("Credenciais inválidas");
        }

        String accessToken = jwtService.generateToken(userJpaEntity.getEmail(), 15);
        String refreshToken = jwtService.generateToken(userJpaEntity.getEmail(), 60 * 24 * 7);

        return AuthResponse.of(accessToken, refreshToken);
    }

    public AuthResponse refresh(RefreshTokenRequest request) {
        String email = jwtService.extractUsername(request.refreshToken());
        userJpaRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        String newAccess = jwtService.generateToken(email, 15);
        return AuthResponse.of(newAccess, request.refreshToken());
    }

    public void logout(String refreshToken) {
        // Estratégia simples: não armazenar refresh token (stateless).
        // Caso fosse stateful, bastaria remover refresh da base.
    }

    public UserJpaEntity getCurrentUser(String token) {
        String email = jwtService.extractUsername(token);
        return userJpaRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
    }
}