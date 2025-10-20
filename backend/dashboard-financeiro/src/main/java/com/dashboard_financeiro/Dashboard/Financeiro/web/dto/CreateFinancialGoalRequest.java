package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalType;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateFinancialGoalRequest(
        @NotBlank(message = "O nome da meta é obrigatório")
        @Size(max = 120, message = "O nome deve ter no máximo 120 caracteres")
        String name,

        @NotNull(message = "O tipo da meta é obrigatório")
        GoalType type,

        UUID categoryId,

        @NotNull(message = "O valor objetivo é obrigatório")
        @Positive(message = "O valor objetivo deve ser positivo")
        BigDecimal targetAmount,

        @NotNull(message = "A data inicial é obrigatória")
        LocalDate startDate,

        @FutureOrPresent(message = "A data final deve ser futura ou presente")
        LocalDate endDate,

        @Size(max = 255, message = "A descrição deve ter no máximo 255 caracteres")
        String description,

        boolean notifyOnAchieve,

        boolean notifyOnExceed
) {
}
