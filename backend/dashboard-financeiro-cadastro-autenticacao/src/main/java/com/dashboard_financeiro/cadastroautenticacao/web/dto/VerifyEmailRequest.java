package com.dashboard_financeiro.cadastroautenticacao.web.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record VerifyEmailRequest(
        @Email(message = "Informe um e-mail válido.")
        @NotBlank(message = "E-mail é obrigatório.")
        String email,

        @NotBlank(message = "Código de verificação é obrigatório.")
        @Size(min = 4, max = 10, message = "Código de verificação inválido.")
        String code
) {
}
