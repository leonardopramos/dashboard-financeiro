package com.dashboard_financeiro.cadastroautenticacao.web.dto;

import jakarta.validation.constraints.NotBlank;

public record RefreshTokenRequest(
        @NotBlank String refreshToken
) {}