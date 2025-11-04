package com.dashboard_financeiro.Dashboard.Financeiro.web.dto;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

public record DashboardOverviewResponse(
        PeriodReference period,
        TimeRange timeRange,
        String appliedRange,
        BigDecimal totalIncome,
        BigDecimal totalExpenses,
        BigDecimal netBalance,
        BigDecimal totalBalance,
        List<CategoryAggregation> categoryBreakdown,
        List<MonthlyTrendPoint> monthlyTrend,
        GoalsSnapshot goals
) {

    public record PeriodReference(int year, int month) {
        public static PeriodReference from(YearMonth yearMonth) {
            return new PeriodReference(yearMonth.getYear(), yearMonth.getMonthValue());
        }
    }

    public record TimeRange(LocalDate startDate, LocalDate endDate, String label) {
    }

    public record CategoryAggregation(
            String categoryId,
            String name,
            String type,
            String color,
            BigDecimal totalIncome,
            BigDecimal totalExpenses
    ) {
    }

    public record MonthlyTrendPoint(
            int year,
            int month,
            BigDecimal income,
            BigDecimal expenses,
            BigDecimal net
    ) {
    }

    public record GoalsSnapshot(
            int total,
            int achieved,
            int exceeded,
            int expired,
            List<GoalProgress> activeGoals
    ) {
    }

    public record GoalProgress(
            String id,
            String name,
            GoalStatus status,
            BigDecimal currentAmount,
            BigDecimal targetAmount,
            Double progressPercentage
    ) {
    }
}
