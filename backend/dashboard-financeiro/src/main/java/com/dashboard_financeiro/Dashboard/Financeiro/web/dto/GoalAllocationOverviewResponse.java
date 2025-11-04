package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record GoalAllocationOverviewResponse(
        TimeRange timeRange,
        String appliedRange,
        BigDecimal accumulated,
        BigDecimal allocated,
        BigDecimal available,
        List<GoalAllocationItem> goals
) {

    public record TimeRange(LocalDate startDate, LocalDate endDate, String label) {
    }

    public record GoalAllocationItem(
            UUID goalId,
            String name,
            GoalStatus status,
            BigDecimal targetAmount,
            BigDecimal currentAmount,
            BigDecimal remainingAmount,
            LocalDate endDate
    ) {
    }
}
