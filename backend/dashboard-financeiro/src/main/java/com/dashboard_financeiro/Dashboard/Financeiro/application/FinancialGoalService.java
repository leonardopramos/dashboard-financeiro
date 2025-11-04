package com.dashboard_financeiro.Dashboard.Financeiro.application;

import com.dashboard_financeiro.Dashboard.Financeiro.application.DashboardRange;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.BusinessException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.ResourceNotFoundException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalStatus;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalType;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.TransactionType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.CategoryJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.FinancialGoalJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.GoalContributionJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.FinancialGoalJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.GoalContributionJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.TransactionJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.messaging.DomainEventPublisher;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.AllocateGoalAmountRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateFinancialGoalRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.FinancialGoalResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.GoalAllocationOverviewResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateFinancialGoalRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class FinancialGoalService {

    private static final DashboardRange DEFAULT_SAVINGS_RANGE = DashboardRange.LAST_12_MONTHS;

    private final FinancialGoalJpaRepository goalRepository;
    private final GoalContributionJpaRepository goalContributionRepository;
    private final TransactionJpaRepository transactionRepository;
    private final CategoryService categoryService;
    private final DomainEventPublisher eventPublisher;

    @Transactional
    public FinancialGoalResponse create(UUID userId, CreateFinancialGoalRequest request) {
        validateDates(request.startDate(), request.endDate());

        CategoryJpaEntity category = null;
        if (request.categoryId() != null) {
            category = categoryService.getEntity(userId, request.categoryId());
        }

        FinancialGoalJpaEntity entity = FinancialGoalJpaEntity.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .name(request.name().trim())
                .type(request.type())
                .category(category)
                .targetAmount(scale(request.targetAmount()))
                .currentAmount(BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP))
                .startDate(request.startDate())
                .endDate(request.endDate())
                .status(GoalStatus.IN_PROGRESS)
                .description(request.description())
                .notifyOnAchieve(request.notifyOnAchieve())
                .notifyOnExceed(request.notifyOnExceed())
                .build();

        FinancialGoalJpaEntity saved = goalRepository.save(entity);
        log.info("Meta financeira {} criada para usuário {}", saved.getId(), userId);
        return FinancialGoalResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public List<FinancialGoalResponse> list(UUID userId) {
        return goalRepository.findByUserIdAndActiveTrueOrderByEndDateAsc(userId)
                .stream()
                .map(FinancialGoalResponse::from)
                .toList();
    }

    @Transactional
    public FinancialGoalResponse update(UUID userId, UUID goalId, UpdateFinancialGoalRequest request) {
        validateDates(request.startDate(), request.endDate());

        FinancialGoalJpaEntity goal = getEntity(userId, goalId);

        CategoryJpaEntity category = null;
        if (request.categoryId() != null) {
            category = categoryService.getEntity(userId, request.categoryId());
        }

        goal.setName(request.name().trim());
        goal.setType(request.type());
        goal.setCategory(category);
        goal.setTargetAmount(scale(request.targetAmount()));
        goal.setStartDate(request.startDate());
        goal.setEndDate(request.endDate());
        goal.setDescription(request.description());
        goal.setNotifyOnAchieve(request.notifyOnAchieve());
        goal.setNotifyOnExceed(request.notifyOnExceed());
        goal.setActive(request.active());

        evaluateGoalStatus(goal);

        FinancialGoalJpaEntity saved = goalRepository.save(goal);
        return FinancialGoalResponse.from(saved);
    }

    @Transactional
    public void delete(UUID userId, UUID goalId) {
        FinancialGoalJpaEntity goal = getEntity(userId, goalId);
        goal.setActive(false);
        goalRepository.save(goal);
    }

    @Transactional(readOnly = true)
    public FinancialGoalJpaEntity getEntity(UUID userId, UUID goalId) {
        return goalRepository.findByIdAndUserId(goalId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Meta financeira não encontrada"));
    }

    @Transactional(readOnly = true)
    public GoalAllocationOverviewResponse getAllocationOverview(UUID userId, DashboardRange range) {
        SavingsWindow window = computeSavingsWindow(userId, range);

        List<GoalAllocationOverviewResponse.GoalAllocationItem> goals = goalRepository
                .findByUserIdAndActiveTrueOrderByEndDateAsc(userId)
                .stream()
                .map(goal -> {
                    BigDecimal target = scale(goal.getTargetAmount());
                    BigDecimal current = scale(goal.getCurrentAmount());
                    BigDecimal remaining = target.subtract(current);
                    if (remaining.signum() < 0) {
                        remaining = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
                    }
                    return new GoalAllocationOverviewResponse.GoalAllocationItem(
                            goal.getId(),
                            goal.getName(),
                            goal.getStatus(),
                            target,
                            current,
                            remaining,
                            goal.getEndDate()
                    );
                })
                .toList();

        GoalAllocationOverviewResponse.TimeRange timeRange = new GoalAllocationOverviewResponse.TimeRange(
                window.start(),
                window.end(),
                window.range().label(Locale.getDefault())
        );

        return new GoalAllocationOverviewResponse(
                timeRange,
                window.range().getQueryValue(),
                window.accumulated(),
                window.allocated(),
                window.available(),
                goals
        );
    }

    @Transactional
    public FinancialGoalResponse allocate(UUID userId, UUID goalId, AllocateGoalAmountRequest request) {
        FinancialGoalJpaEntity goal = getEntity(userId, goalId);

        BigDecimal amount = scale(request.amount());
        if (amount.signum() <= 0) {
            throw new BusinessException("Informe um valor positivo para destinar à meta.");
        }

        SavingsWindow window = computeSavingsWindow(userId, DEFAULT_SAVINGS_RANGE);
        if (amount.compareTo(window.available()) > 0) {
            throw new BusinessException("Saldo acumulado insuficiente para essa destinação.");
        }

        BigDecimal remaining = scale(goal.getTargetAmount()).subtract(scale(goal.getCurrentAmount()));
        if (remaining.signum() <= 0) {
            throw new BusinessException("Esta meta já foi concluída.");
        }
        if (amount.compareTo(remaining) > 0) {
            throw new BusinessException("O valor informado excede o saldo necessário para concluir a meta.");
        }

        GoalContributionJpaEntity contribution = GoalContributionJpaEntity.builder()
                .goal(goal)
                .userId(userId)
                .amount(amount)
                .description(StringUtils.hasText(request.description()) ? request.description().trim() : null)
                .allocationDate(LocalDate.now())
                .build();
        goalContributionRepository.save(contribution);

        BigDecimal newAmount = scale(goal.getCurrentAmount().add(amount));
        goal.setCurrentAmount(newAmount);

        GoalStatus previous = goal.getStatus();
        evaluateGoalStatus(goal);
        FinancialGoalJpaEntity saved = goalRepository.save(goal);

        if (previous != saved.getStatus()) {
            eventPublisher.publishGoalStatusChanges(List.of(new GoalStatusChange(saved, previous)));
        }

        log.info("Destinação de {} aplicada à meta {} do usuário {}", amount, goal.getId(), userId);
        return FinancialGoalResponse.from(saved);
    }

    private SavingsWindow computeSavingsWindow(UUID userId, DashboardRange requestedRange) {
        DashboardRange effectiveRange = requestedRange != null ? requestedRange : DEFAULT_SAVINGS_RANGE;
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = effectiveRange.resolveStartDate(endDate);

        List<TransactionJpaEntity> transactions = transactionRepository
                .findByBankAccountUserIdAndTransactionDateBetween(userId, startDate, endDate);

        BigDecimal accumulated = sumIncome(transactions).subtract(sumExpenses(transactions));
        if (accumulated.signum() < 0) {
            accumulated = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }

        BigDecimal allocated = goalContributionRepository.sumByUserBetween(userId, startDate, endDate);
        if (allocated == null) {
            allocated = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        } else {
            allocated = allocated.setScale(2, RoundingMode.HALF_UP);
        }

        BigDecimal available = accumulated.subtract(allocated);
        if (available.signum() < 0) {
            available = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        } else {
            available = available.setScale(2, RoundingMode.HALF_UP);
        }

        return new SavingsWindow(effectiveRange, startDate, endDate, accumulated.setScale(2, RoundingMode.HALF_UP), allocated, available);
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

    private void evaluateGoalStatus(FinancialGoalJpaEntity goal) {
        GoalStatus newStatus = GoalStatus.IN_PROGRESS;
        LocalDate today = LocalDate.now();

        if (goal.getType() == GoalType.SAVINGS) {
            if (goal.getCurrentAmount().compareTo(goal.getTargetAmount()) >= 0) {
                newStatus = GoalStatus.ACHIEVED;
            } else if (goal.getEndDate() != null && today.isAfter(goal.getEndDate())) {
                newStatus = GoalStatus.EXPIRED;
            }
        } else if (goal.getType() == GoalType.EXPENSE_LIMIT) {
            if (goal.getCurrentAmount().compareTo(goal.getTargetAmount()) > 0) {
                newStatus = GoalStatus.EXCEEDED;
            } else if (goal.getEndDate() != null && today.isAfter(goal.getEndDate())) {
                newStatus = GoalStatus.EXPIRED;
            }
        }

        if (newStatus == GoalStatus.ACHIEVED && goal.getAchievedAt() == null) {
            goal.setAchievedAt(LocalDateTime.now());
        }

        goal.setStatus(newStatus);
    }

    private boolean isIncome(TransactionJpaEntity transaction) {
        return transaction.getType() == TransactionType.INCOME || transaction.getType() == TransactionType.TRANSFER_IN;
    }

    private boolean isExpense(TransactionJpaEntity transaction) {
        return transaction.getType() == TransactionType.EXPENSE || transaction.getType() == TransactionType.TRANSFER_OUT;
    }

    private record SavingsWindow(
            DashboardRange range,
            LocalDate start,
            LocalDate end,
            BigDecimal accumulated,
            BigDecimal allocated,
            BigDecimal available
    ) {
    }

    private void validateDates(LocalDate start, LocalDate end) {
        if (end != null && end.isBefore(start)) {
            throw new BusinessException("A data final deve ser igual ou posterior à data inicial");
        }
    }

    private BigDecimal scale(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP);
    }

    public record GoalStatusChange(
            FinancialGoalJpaEntity goal,
            GoalStatus previousStatus
    ) {
    }
}
