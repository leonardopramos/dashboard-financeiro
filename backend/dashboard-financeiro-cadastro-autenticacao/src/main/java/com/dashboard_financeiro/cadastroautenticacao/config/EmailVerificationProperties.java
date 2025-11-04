package com.dashboard_financeiro.cadastroautenticacao.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "verification.email")
public record EmailVerificationProperties(
        int codeLength,
        int expirationMinutes,
        int resendCooldownMinutes,
        int maxAttempts
) {
    public EmailVerificationProperties {
        if (codeLength < 4) {
            throw new IllegalArgumentException("O código de verificação deve ter pelo menos 4 dígitos.");
        }
        if (expirationMinutes <= 0) {
            throw new IllegalArgumentException("O tempo de expiração do código deve ser positivo.");
        }
        if (resendCooldownMinutes < 0) {
            throw new IllegalArgumentException("O tempo mínimo entre reenvios não pode ser negativo.");
        }
        if (maxAttempts <= 0) {
            throw new IllegalArgumentException("O número máximo de tentativas deve ser positivo.");
        }
    }
}
