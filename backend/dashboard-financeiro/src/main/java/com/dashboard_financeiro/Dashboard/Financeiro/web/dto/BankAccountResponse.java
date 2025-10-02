package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.AccountType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.BankAccountJpaEntity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record BankAccountResponse(
        UUID id,
        UUID userId,
        String institutionName,
        String branchNumber,
        String accountNumber,
        String accountDigit,
        AccountType accountType,
        String nickname,
        BigDecimal currentBalance,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static BankAccountResponse from(BankAccountJpaEntity entity) {
        return new BankAccountResponse(
                entity.getId(),
                entity.getUserId(),
                entity.getInstitutionName(),
                entity.getBranchNumber(),
                entity.getAccountNumber(),
                entity.getAccountDigit(),
                entity.getAccountType(),
                entity.getNickname(),
                entity.getCurrentBalance(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
