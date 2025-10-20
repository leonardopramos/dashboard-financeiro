package com.dashboard_financeiro.Dashboard.Financeiro.messaging.event;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record TransactionCreatedEvent(
        UUID transactionId,
        UUID userId,
        UUID bankAccountId,
        String type,
        BigDecimal amount,
        LocalDate transactionDate,
        String description,
        String categoryId,
        String categoryName,
        LocalDateTime createdAt
) {
}
