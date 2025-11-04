package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record AllocateGoalAmountRequest(
        @NotNull(message = "Informe o valor a destinar para a meta")
        @Positive(message = "O valor deve ser positivo")
        BigDecimal amount,

        @Size(max = 255, message = "A observação deve ter no máximo 255 caracteres")
        String description
) {
}
