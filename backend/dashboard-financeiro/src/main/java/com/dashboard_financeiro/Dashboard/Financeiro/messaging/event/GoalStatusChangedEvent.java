package com.dashboard_financeiro.Dashboard.Financeiro.messaging.event;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record GoalStatusChangedEvent(
        UUID goalId,
        UUID userId,
        String name,
        String type,
        String status,
        String previousStatus,
        BigDecimal currentAmount,
        BigDecimal targetAmount,
        LocalDate startDate,
        LocalDate endDate,
        String categoryId,
        String categoryName,
        LocalDateTime achievedAt,
        LocalDateTime updatedAt
) {
}
