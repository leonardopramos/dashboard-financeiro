package com.dashboard_financeiro.Dashboard.Financeiro.application;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalStatus;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.TransactionType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.BankAccountJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.FinancialGoalJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.BankAccountJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.FinancialGoalJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.TransactionJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.DashboardOverviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final TransactionJpaRepository transactionRepository;
    private final BankAccountJpaRepository bankAccountRepository;
    private final FinancialGoalJpaRepository financialGoalRepository;

    @Transactional(readOnly = true)
    public DashboardOverviewResponse getOverview(UUID userId, YearMonth reference, DashboardRange range) {
        LocalDate today = LocalDate.now();
        YearMonth basePeriod = reference != null ? reference : YearMonth.from(today);
        LocalDate defaultStart = basePeriod.atDay(1);
        LocalDate defaultEnd = basePeriod.atEndOfMonth();

        LocalDate rangeStart = range != null ? range.resolveStartDate(today) : defaultStart;
        LocalDate rangeEnd = range != null ? today : defaultEnd;

        List<TransactionJpaEntity> scopedTransactions = transactionRepository
                .findByBankAccountUserIdAndTransactionDateBetween(userId, rangeStart, rangeEnd);

        BigDecimal totalIncome = sumIncome(scopedTransactions);
        BigDecimal totalExpenses = sumExpenses(scopedTransactions);
        BigDecimal netBalance = totalIncome.subtract(totalExpenses).setScale(2, RoundingMode.HALF_UP);

        BigDecimal totalBalance = bankAccountRepository.findByUserId(userId)
                .stream()
                .map(BankAccountJpaEntity::getCurrentBalance)
                .reduce(BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP), BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);

        List<DashboardOverviewResponse.CategoryAggregation> categoryAggregations = buildCategoryBreakdown(scopedTransactions);

        List<DashboardOverviewResponse.MonthlyTrendPoint> trendPoints;
        if (range != null) {
            trendPoints = buildTrend(scopedTransactions, rangeStart, rangeEnd);
        } else {
            YearMonth startTrendPeriod = basePeriod.minusMonths(5);
            LocalDate trendStart = startTrendPeriod.atDay(1);
            List<TransactionJpaEntity> trendTransactions = transactionRepository
                    .findByBankAccountUserIdAndTransactionDateBetween(userId, trendStart, defaultEnd);
            trendPoints = buildTrend(trendTransactions, trendStart, defaultEnd);
        }

        DashboardOverviewResponse.GoalsSnapshot goalsSnapshot = buildGoalsSnapshot(userId);
        DashboardOverviewResponse.TimeRange timeRange = new DashboardOverviewResponse.TimeRange(
                rangeStart,
                rangeEnd,
                range != null ? range.label(Locale.getDefault()) : null
        );

        return new DashboardOverviewResponse(
                DashboardOverviewResponse.PeriodReference.from(YearMonth.from(rangeEnd)),
                timeRange,
                range != null ? range.getQueryValue() : null,
                totalIncome,
                totalExpenses,
                netBalance,
                totalBalance,
                categoryAggregations,
                trendPoints,
                goalsSnapshot
        );
    }

    private BigDecimal sumIncome(List<TransactionJpaEntity> transactions) {
        return transactions.stream()
                .filter(this::isIncome)
                .map(TransactionJpaEntity::getAmount)
                .reduce(BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP), BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal sumExpenses(List<TransactionJpaEntity> transactions) {
        return transactions.stream()
                .filter(this::isExpense)
                .map(TransactionJpaEntity::getAmount)
                .reduce(BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP), BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);
    }

    private List<DashboardOverviewResponse.CategoryAggregation> buildCategoryBreakdown(List<TransactionJpaEntity> transactions) {
        Map<String, CategoryAccumulator> accumulatorMap = new HashMap<>();

        for (TransactionJpaEntity transaction : transactions) {
            String key = transaction.getCategory() != null ? transaction.getCategory().getId().toString() : "UNCATEGORIZED";
            CategoryAccumulator accumulator = accumulatorMap.computeIfAbsent(key, k -> new CategoryAccumulator(transaction));
            if (isIncome(transaction)) {
                accumulator.income = accumulator.income.add(transaction.getAmount());
            } else if (isExpense(transaction)) {
                accumulator.expense = accumulator.expense.add(transaction.getAmount());
            }
        }

        return accumulatorMap.values().stream()
                .map(CategoryAccumulator::toAggregation)
                .toList();
    }

    private List<DashboardOverviewResponse.MonthlyTrendPoint> buildTrend(List<TransactionJpaEntity> transactions,
                                                                         LocalDate startInclusive,
                                                                         LocalDate endInclusive) {
        Map<YearMonth, TrendAccumulator> map = new HashMap<>();
        YearMonth startMonth = YearMonth.from(startInclusive);
        YearMonth endMonth = YearMonth.from(endInclusive);

        for (TransactionJpaEntity transaction : transactions) {
            YearMonth ym = YearMonth.from(transaction.getTransactionDate());
            if (ym.isBefore(startMonth) || ym.isAfter(endMonth)) {
                continue;
            }

            TrendAccumulator accumulator = map.computeIfAbsent(ym, key -> new TrendAccumulator());
            if (isIncome(transaction)) {
                accumulator.income = accumulator.income.add(transaction.getAmount());
            } else if (isExpense(transaction)) {
                accumulator.expense = accumulator.expense.add(transaction.getAmount());
            }
        }

        List<DashboardOverviewResponse.MonthlyTrendPoint> points = new ArrayList<>();
        YearMonth cursor = startMonth;
        while (!cursor.isAfter(endMonth)) {
            TrendAccumulator accumulator = map.getOrDefault(cursor, new TrendAccumulator());
            BigDecimal income = accumulator.income.setScale(2, RoundingMode.HALF_UP);
            BigDecimal expenses = accumulator.expense.setScale(2, RoundingMode.HALF_UP);
            points.add(new DashboardOverviewResponse.MonthlyTrendPoint(
                    cursor.getYear(),
                    cursor.getMonthValue(),
                    income,
                    expenses,
                    income.subtract(expenses).setScale(2, RoundingMode.HALF_UP)
            ));
            cursor = cursor.plusMonths(1);
        }

        return points;
    }

    private DashboardOverviewResponse.GoalsSnapshot buildGoalsSnapshot(UUID userId) {
        List<FinancialGoalJpaEntity> goals = financialGoalRepository.findByUserIdAndActiveTrueOrderByEndDateAsc(userId);
        int achieved = 0;
        int exceeded = 0;
        int expired = 0;

        List<DashboardOverviewResponse.GoalProgress> progressList = new ArrayList<>();

        for (FinancialGoalJpaEntity goal : goals) {
            GoalStatus status = goal.getStatus();
            if (status == GoalStatus.ACHIEVED) {
                achieved++;
            } else if (status == GoalStatus.EXCEEDED) {
                exceeded++;
            } else if (status == GoalStatus.EXPIRED) {
                expired++;
            }

            BigDecimal target = goal.getTargetAmount();
            BigDecimal current = goal.getCurrentAmount();
            double progress = BigDecimal.ZERO.compareTo(target) == 0
                    ? 0.0
                    : current.divide(target, 4, RoundingMode.HALF_UP).doubleValue();
            progress = Math.min(progress, 1.0);

            progressList.add(new DashboardOverviewResponse.GoalProgress(
                    goal.getId().toString(),
                    goal.getName(),
                    status,
                    current.setScale(2, RoundingMode.HALF_UP),
                    target.setScale(2, RoundingMode.HALF_UP),
                    progress * 100.0
            ));
        }

        return new DashboardOverviewResponse.GoalsSnapshot(
                goals.size(),
                achieved,
                exceeded,
                expired,
                progressList
        );
    }

    private boolean isIncome(TransactionJpaEntity transaction) {
        return transaction.getType() == TransactionType.INCOME || transaction.getType() == TransactionType.TRANSFER_IN;
    }

    private boolean isExpense(TransactionJpaEntity transaction) {
        return transaction.getType() == TransactionType.EXPENSE || transaction.getType() == TransactionType.TRANSFER_OUT;
    }

    private static class TrendAccumulator {
        private BigDecimal income = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        private BigDecimal expense = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
    }

    private static class CategoryAccumulator {
        private final String categoryId;
        private final String name;
        private final String type;
        private final String color;
        private BigDecimal income = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        private BigDecimal expense = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);

        private CategoryAccumulator(TransactionJpaEntity sample) {
            if (sample.getCategory() != null) {
                this.categoryId = sample.getCategory().getId().toString();
                this.name = sample.getCategory().getName();
                this.type = sample.getCategory().getType().name();
                this.color = sample.getCategory().getColor();
            } else {
                this.categoryId = "UNCATEGORIZED";
                this.name = "Sem categoria";
                this.type = "UNASSIGNED";
                this.color = null;
            }
        }

        private DashboardOverviewResponse.CategoryAggregation toAggregation() {
            return new DashboardOverviewResponse.CategoryAggregation(
                    categoryId,
                    name,
                    type,
                    color,
                    income.setScale(2, RoundingMode.HALF_UP),
                    expense.setScale(2, RoundingMode.HALF_UP)
            );
        }
    }
}
