package com.dashboard_financeiro.cadastroautenticacao.web.controller;

import com.dashboard_financeiro.cadastroautenticacao.application.AuthService;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.AuthResponse;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.LoginRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.RefreshTokenRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.ResendVerificationRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.VerifyEmailRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Autenticação")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(
            summary = "Login",
            description = "Valida credenciais e gera tokens JWT (acesso e refresh) para o usuário."
    )
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    @Operation(
            summary = "Renovar token",
            description = "Gera um novo par de tokens a partir de um refresh token válido."
    )
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refresh(request));
    }

    @PostMapping("/logout")
    @Operation(
            summary = "Logout",
            description = "Invalida o refresh token informado, encerrando a sessão do usuário."
    )
    public ResponseEntity<?> logout(@Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(request.refreshToken());
        return ResponseEntity.ok().body("{\"message\": \"Logout realizado com sucesso.\"}");
    }

    @GetMapping("/me")
    @Operation(
            summary = "Dados do usuário autenticado",
            description = "Retorna o perfil básico extraído do JWT enviado no cabeçalho Authorization."
    )
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<UserDTO> me(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token == null || !token.startsWith("Bearer ")) {
            return ResponseEntity.status(401).build();
        }
        String jwt = token.substring(7);
        UserDTO current = authService.getCurrentUser(jwt);
        return ResponseEntity.ok(current);
    }

    @PostMapping("/verify-email")
    @Operation(
            summary = "Confirmar e-mail",
            description = "Valida o código de verificação enviado por e-mail para ativar a conta."
    )
    public ResponseEntity<Map<String, String>> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        authService.verifyEmail(request.email(), request.code());
        return ResponseEntity.ok(Map.of("message", "E-mail verificado com sucesso. Você já pode fazer login."));
    }

    @PostMapping("/verify-email/resend")
    @Operation(
            summary = "Reenviar código de verificação",
            description = "Dispara um novo código de confirmação para o e-mail informado."
    )
    public ResponseEntity<Map<String, String>> resendVerification(@Valid @RequestBody ResendVerificationRequest request) {
        authService.resendVerification(request.email());
        return ResponseEntity.ok(Map.of("message", "Um novo código de verificação foi enviado para o seu e-mail."));
    }
}
