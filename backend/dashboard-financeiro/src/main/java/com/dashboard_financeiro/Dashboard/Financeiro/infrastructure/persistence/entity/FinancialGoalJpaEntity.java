package com.dashboard_financeiro.Dashboard.Financeiro.infrastructure.persistence.entity;

import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalStatus;
import com.dashboard_financeiro.Dashboard.Financeiro.domain.model.GoalType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "financial_goals")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FinancialGoalJpaEntity {

    @Id
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "name", nullable = false, length = 120)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "goal_type", nullable = false, length = 30)
    private GoalType type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private CategoryJpaEntity category;

    @Column(name = "target_amount", nullable = false, precision = 19, scale = 2)
    private BigDecimal targetAmount;

    @Column(name = "current_amount", nullable = false, precision = 19, scale = 2)
    private BigDecimal currentAmount;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "goal_status", nullable = false, length = 30)
    private GoalStatus status;

    @Column(name = "description", length = 255)
    private String description;

    @Column(name = "active", nullable = false)
    private boolean active;

    @Column(name = "notify_on_achieve", nullable = false)
    private boolean notifyOnAchieve;

    @Column(name = "notify_on_exceed", nullable = false)
    private boolean notifyOnExceed;

    @Column(name = "achieved_at")
    private LocalDateTime achievedAt;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        var now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
        active = true;
        if (currentAmount == null) {
            currentAmount = BigDecimal.ZERO;
        }
        if (status == null) {
            status = GoalStatus.IN_PROGRESS;
        }
        if (id == null) {
            id = UUID.randomUUID();
        }
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
