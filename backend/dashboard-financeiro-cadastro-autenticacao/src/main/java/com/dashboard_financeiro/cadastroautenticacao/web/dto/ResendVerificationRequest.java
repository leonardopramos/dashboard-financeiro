package com.dashboard_financeiro.cadastroautenticacao.web.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record ResendVerificationRequest(
        @Email(message = "Informe um e-mail válido.")
        @NotBlank(message = "E-mail é obrigatório.")
        String email
) {
}
