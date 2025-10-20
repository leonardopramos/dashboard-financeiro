package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalStatus;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.FinancialGoalJpaEntity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record FinancialGoalResponse(
        UUID id,
        UUID userId,
        String name,
        GoalType type,
        CategoryResponse category,
        BigDecimal targetAmount,
        BigDecimal currentAmount,
        LocalDate startDate,
        LocalDate endDate,
        GoalStatus status,
        String description,
        boolean active,
        boolean notifyOnAchieve,
        boolean notifyOnExceed,
        LocalDateTime achievedAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static FinancialGoalResponse from(FinancialGoalJpaEntity entity) {
        CategoryResponse categoryResponse = entity.getCategory() != null
                ? CategoryResponse.from(entity.getCategory())
                : null;

        return new FinancialGoalResponse(
                entity.getId(),
                entity.getUserId(),
                entity.getName(),
                entity.getType(),
                categoryResponse,
                entity.getTargetAmount(),
                entity.getCurrentAmount(),
                entity.getStartDate(),
                entity.getEndDate(),
                entity.getStatus(),
                entity.getDescription(),
                entity.isActive(),
                entity.isNotifyOnAchieve(),
                entity.isNotifyOnExceed(),
                entity.getAchievedAt(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
