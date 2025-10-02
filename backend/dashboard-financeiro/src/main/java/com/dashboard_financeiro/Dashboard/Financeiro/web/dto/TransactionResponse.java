package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.TransactionType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record TransactionResponse(
        UUID id,
        UUID userId,
        UUID bankAccountId,
        TransactionType type,
        BigDecimal amount,
        LocalDate transactionDate,
        String description,
        String category,
        String notes,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static TransactionResponse from(TransactionJpaEntity entity) {
        return new TransactionResponse(
                entity.getId(),
                entity.getBankAccount().getUserId(),
                entity.getBankAccount().getId(),
                entity.getType(),
                entity.getAmount(),
                entity.getTransactionDate(),
                entity.getDescription(),
                entity.getCategory(),
                entity.getNotes(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
