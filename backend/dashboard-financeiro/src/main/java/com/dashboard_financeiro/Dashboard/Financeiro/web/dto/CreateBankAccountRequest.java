package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.AccountType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record CreateBankAccountRequest(
        @NotBlank(message = "O nome da instituição é obrigatório")
        @Size(max = 120, message = "O nome da instituição deve ter no máximo 120 caracteres")
        String institutionName,

        @NotBlank(message = "O número da agência é obrigatório")
        @Size(max = 20, message = "O número da agência deve ter no máximo 20 caracteres")
        String branchNumber,

        @NotBlank(message = "O número da conta é obrigatório")
        @Size(max = 30, message = "O número da conta deve ter no máximo 30 caracteres")
        String accountNumber,

        @Size(max = 5, message = "O dígito da conta deve ter no máximo 5 caracteres")
        String accountDigit,

        @NotNull(message = "O tipo de conta é obrigatório")
        AccountType accountType,

        @Size(max = 60, message = "O apelido deve ter no máximo 60 caracteres")
        String nickname,

        BigDecimal initialBalance
) {
}
