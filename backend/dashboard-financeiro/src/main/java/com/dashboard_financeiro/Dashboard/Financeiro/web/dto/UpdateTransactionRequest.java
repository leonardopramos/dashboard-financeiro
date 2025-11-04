package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.TransactionType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record UpdateTransactionRequest(
        @NotNull(message = "O identificador da conta bancária é obrigatório")
        UUID bankAccountId,

        @NotNull(message = "O tipo de transação é obrigatório")
        TransactionType type,

        @NotNull(message = "O valor da transação é obrigatório")
        @Positive(message = "O valor deve ser positivo")
        BigDecimal amount,

        @NotNull(message = "A data da transação é obrigatória")
        LocalDate transactionDate,

        @NotBlank(message = "A descrição é obrigatória")
        @Size(max = 200, message = "A descrição deve ter no máximo 200 caracteres")
        String description,

        UUID categoryId,

        @Size(max = 255, message = "As observações devem ter no máximo 255 caracteres")
        String notes
) {
}
