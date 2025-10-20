package com.dashboard_financeiro.Dashboard.Financeiro.application;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.BusinessException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.exception.ResourceNotFoundException;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalStatus;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalType;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.TransactionType;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.CategoryJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.FinancialGoalJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity.TransactionJpaEntity;
import com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.repository.FinancialGoalJpaRepository;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.CreateFinancialGoalRequest;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.FinancialGoalResponse;
import com.dashboard_financeiro.Dashboard.Financeiro.web.dto.UpdateFinancialGoalRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class FinancialGoalService {

    private final FinancialGoalJpaRepository goalRepository;
    private final CategoryService categoryService;

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

    @Transactional
    public List<GoalStatusChange> processTransaction(UUID userId, TransactionJpaEntity transaction) {
        List<FinancialGoalJpaEntity> goals = goalRepository.findByUserIdAndActiveTrueOrderByEndDateAsc(userId);
        if (goals.isEmpty()) {
            return List.of();
        }

        List<GoalStatusChange> statusChanges = new ArrayList<>();

        for (FinancialGoalJpaEntity goal : goals) {
            if (!matchesGoal(goal, transaction)) {
                continue;
            }

            BigDecimal delta = computeDelta(goal.getType(), transaction);
            if (delta.signum() == 0) {
                continue;
            }

            BigDecimal newAmount = scale(goal.getCurrentAmount().add(delta));
            goal.setCurrentAmount(newAmount);

            GoalStatus previous = goal.getStatus();
            evaluateGoalStatus(goal);

            goalRepository.save(goal);

            if (previous != goal.getStatus()
                    || (goal.getStatus() == GoalStatus.ACHIEVED && goal.isNotifyOnAchieve())
                    || (goal.getStatus() == GoalStatus.EXCEEDED && goal.isNotifyOnExceed())) {
                statusChanges.add(new GoalStatusChange(goal, previous));
            }
        }

        return statusChanges;
    }

    private boolean matchesGoal(FinancialGoalJpaEntity goal, TransactionJpaEntity transaction) {
        if (goal.getCategory() != null) {
            if (transaction.getCategory() == null) {
                return false;
            }
            if (!goal.getCategory().getId().equals(transaction.getCategory().getId())) {
                return false;
            }
        }

        if (goal.getType() == GoalType.SAVINGS) {
            return isIncome(transaction);
        }

        if (goal.getType() == GoalType.EXPENSE_LIMIT) {
            return isExpense(transaction);
        }

        return false;
    }

    private BigDecimal computeDelta(GoalType goalType, TransactionJpaEntity transaction) {
        BigDecimal amount = transaction.getAmount().setScale(2, RoundingMode.HALF_UP);
        if (goalType == GoalType.SAVINGS && isIncome(transaction)) {
            return amount;
        }
        if (goalType == GoalType.EXPENSE_LIMIT && isExpense(transaction)) {
            return amount;
        }
        return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
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
