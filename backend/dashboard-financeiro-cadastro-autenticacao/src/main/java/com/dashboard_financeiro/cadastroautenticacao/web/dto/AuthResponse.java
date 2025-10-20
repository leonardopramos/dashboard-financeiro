package com.dashboard_financeiro.cadastroautenticacao.web.dto;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        UserDTO user
) {
    public static AuthResponse of(String access, String refresh, UserDTO user) {
        return new AuthResponse(access, refresh, "Bearer", user);
    }
}
