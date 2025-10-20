package com.dashboard_financeiro.cadastroautenticacao.web.controller;

import com.dashboard_financeiro.cadastroautenticacao.application.AuthService;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.AuthResponse;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.LoginRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.RefreshTokenRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
}
