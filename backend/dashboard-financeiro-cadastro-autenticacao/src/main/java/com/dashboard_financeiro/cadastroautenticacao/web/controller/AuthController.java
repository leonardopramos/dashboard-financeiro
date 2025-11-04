package com.dashboard_financeiro.cadastroautenticacao.web.controller;

import com.dashboard_financeiro.cadastroautenticacao.application.AuthService;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.AuthResponse;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.LoginRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.RefreshTokenRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.ResendVerificationRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.VerifyEmailRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refresh(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(@Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(request.refreshToken());
        return ResponseEntity.ok().body("{\"message\": \"Logout realizado com sucesso.\"}");
    }

    @GetMapping("/me")
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
    public ResponseEntity<Map<String, String>> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        authService.verifyEmail(request.email(), request.code());
        return ResponseEntity.ok(Map.of("message", "E-mail verificado com sucesso. Você já pode fazer login."));
    }

    @PostMapping("/verify-email/resend")
    public ResponseEntity<Map<String, String>> resendVerification(@Valid @RequestBody ResendVerificationRequest request) {
        authService.resendVerification(request.email());
        return ResponseEntity.ok(Map.of("message", "Um novo código de verificação foi enviado para o seu e-mail."));
    }
}
